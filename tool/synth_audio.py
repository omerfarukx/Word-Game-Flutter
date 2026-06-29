import numpy as np, wave, os, struct

SR = 44100
OUT = os.path.dirname(os.path.abspath(__file__))

def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)

def env_adsr(n, a, d, s_level, r):
    a=int(a*SR); d=int(d*SR); r=int(r*SR)
    s=max(0, n-a-d-r)
    e=np.concatenate([
        np.linspace(0,1,a,endpoint=False) if a else np.array([]),
        np.linspace(1,s_level,d,endpoint=False) if d else np.array([]),
        np.full(s, s_level),
        np.linspace(s_level,0,r) if r else np.array([]),
    ])
    if len(e)<n: e=np.concatenate([e,np.zeros(n-len(e))])
    return e[:n]

def tone(freq, dur, harms=(1,0.5,0.25,0.12), detune=0.0, a=0.005, d=0.08, s=0.6, r=0.2, decay=0.0):
    n=int(dur*SR); t=np.arange(n)/SR
    x=np.zeros(n)
    for i,amp in enumerate(harms):
        f=freq*(i+1)
        x+=amp*np.sin(2*np.pi*f*t)
        if detune:
            x+=amp*0.5*np.sin(2*np.pi*f*(1+detune)*t)
    e=env_adsr(n,a,d,s,r)
    if decay: e=e*np.exp(-decay*t)
    return x*e

def pad(freq, dur, detune=0.006, a=0.4, r=0.6):
    # warm pad: stacked detuned saw-ish (sine sum) through gentle lowpass
    n=int(dur*SR); t=np.arange(n)/SR
    x=np.zeros(n)
    for k in range(1,7):
        amp=1.0/k
        x+=amp*np.sin(2*np.pi*freq*k*t)
        x+=amp*np.sin(2*np.pi*freq*k*(1+detune)*t)
    # one-pole lowpass
    a_lp=0.06
    y=np.zeros(n); acc=0.0
    # vectorized one-pole approximation via cumulative filtering
    b=a_lp
    yv=np.empty(n); prev=0.0
    for i in range(0,n,2048):
        seg=x[i:i+2048]
        out=np.empty(len(seg))
        p=prev
        for j,v in enumerate(seg):
            p=p+b*(v-p); out[j]=p
        yv[i:i+len(seg)]=out; prev=p
    e=env_adsr(n,a,0.1,0.85,r)
    return yv*e

def reverb(x, ir_dur=0.5, decay=6.0, mix=0.25, lp=0.5):
    m=int(ir_dur*SR)
    ir=np.random.randn(m)*np.exp(-np.linspace(0,decay,m))
    # smooth ir a touch
    ir=np.convolve(ir,np.ones(40)/40,mode='same')
    N=1
    L=len(x)+m-1
    while N<L: N*=2
    X=np.fft.rfft(x,N); H=np.fft.rfft(ir,N)
    wet=np.fft.irfft(X*H,N)[:len(x)]
    wet=wet/ (np.max(np.abs(wet))+1e-9)
    return x*(1-mix)+wet*mix*np.max(np.abs(x))

def master(x, peak=0.89):
    x=np.tanh(x*1.1)
    x=x/(np.max(np.abs(x))+1e-9)*peak
    return x

def save(name, x):
    x=master(x)
    data=(x*32767).astype(np.int16)
    p=os.path.join(OUT,name+'.wav')
    with wave.open(p,'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(data.tobytes())
    print('wrote',p,len(x)/SR,'s')

def seq(notes, total=None):
    # notes: list of (start, dur, signal)
    if total is None:
        total=max(s+len(sig)/SR for s,_,sig in notes)
    n=int(total*SR); buf=np.zeros(n)
    for s,_,sig in notes:
        i=int(s*SR); j=min(n,i+len(sig)); buf[i:j]+=sig[:j-i]
    return buf

def loop_wrap(x, xfade=1.0):
    # make seamless: crossfade tail into head
    f=int(xfade*SR)
    if f*2>=len(x): return x
    head=x[:f].copy(); tail=x[-f:].copy()
    fade=np.linspace(0,1,f)
    x[:f]=head*fade+tail*(1-fade)
    return x[:-f]

# ---------- SFX ----------
def sfx_correct():
    a=tone(midi(76),0.30,harms=(1,0.6,0.3),decay=8,a=0.003,d=0.05,s=0.5,r=0.15)  # E5
    b=tone(midi(83),0.40,harms=(1,0.6,0.3),decay=7,a=0.003,d=0.05,s=0.5,r=0.2)   # B5
    x=seq([(0,0,a),(0.09,0,b)],total=0.55)
    return reverb(x,mix=0.22)

def sfx_combo():
    notes=[]
    for i,m in enumerate([72,76,79,84]):  # C maj arpeggio up
        notes.append((i*0.06,0,tone(midi(m),0.35,harms=(1,0.5,0.25,0.12),decay=9,a=0.002,d=0.04,s=0.5,r=0.15)))
    x=seq(notes,total=0.7)
    return reverb(x,mix=0.25)

def sfx_wrong():
    n=int(0.32*SR); t=np.arange(n)/SR
    f=np.linspace(220,150,n)  # downward
    x=0.6*np.sin(2*np.pi*np.cumsum(f)/SR)
    x+=0.15*np.sin(2*np.pi*np.cumsum(f*0.5)/SR)
    e=env_adsr(n,0.005,0.05,0.5,0.18)*np.exp(-5*t)
    return reverb(x*e,mix=0.12)

def sfx_level():
    notes=[]
    for i,m in enumerate([67,72,76,79,84]):  # G C E G C fanfare
        notes.append((i*0.10,0,tone(midi(m),0.5,harms=(1,0.6,0.35,0.18,0.1),decay=5,a=0.004,d=0.06,s=0.6,r=0.25)))
    x=seq(notes,total=1.1)
    return reverb(x,mix=0.3,ir_dur=0.7)

def sfx_achieve():
    # triumphant major chord with shimmer
    chord=[60,64,67,72]
    x=seq([(0,0,tone(midi(m),1.3,harms=(1,0.6,0.4,0.25,0.15),detune=0.004,a=0.01,d=0.2,s=0.7,r=0.5,decay=1.5)) for m in chord],total=1.4)
    # shimmer octave bells
    x=x+0.4*seq([(0.15+i*0.07,0,tone(midi(m+12),0.6,harms=(1,0.4),decay=8,a=0.002,d=0.03,s=0.4,r=0.2)) for i,m in enumerate(chord)],total=1.4)
    return reverb(x,mix=0.35,ir_dur=0.9)

# ---------- MUSIC (per category) ----------
def music(chords, root_oct=4, arp_oct=5, bpm=68, bars=4, beats=4, arp_pattern=(0,1,2,1), arp_amp=0.5, pad_amp=0.5, detune=0.006):
    beat=60/bpm
    chord_dur=beat*beats
    total=chord_dur*len(chords)
    n=int(total*SR); buf=np.zeros(n)
    for ci,ch in enumerate(chords):
        start=ci*chord_dur
        # pad chord
        for m in ch:
            sig=pad(midi(m),chord_dur*1.02,detune=detune,a=0.5,r=0.5)*pad_amp
            i=int(start*SR); j=min(n,i+len(sig)); buf[i:j]+=sig[:j-i]
        # arpeggio
        steps=beats*2
        for sidx in range(steps):
            deg=arp_pattern[sidx%len(arp_pattern)]
            note_m=ch[deg%len(ch)]+12
            ns=start+sidx*(chord_dur/steps)
            sig=tone(midi(note_m),chord_dur/steps*1.5,harms=(1,0.5,0.2),decay=6,a=0.004,d=0.05,s=0.4,r=0.2)*arp_amp
            i=int(ns*SR); j=min(n,i+len(sig)); buf[i:j]+=sig[:j-i]
    buf=reverb(buf,mix=0.3,ir_dur=0.8,decay=5)
    buf=loop_wrap(buf,xfade=1.2)
    return buf

# Kelime (warm, F major: F Dm Bb C)
def music_word():
    F=[53,57,60]; Dm=[50,53,57]; Bb=[46,50,53]; C=[48,52,55]
    return music([F,Dm,Bb,C],bpm=66,pad_amp=0.45,arp_amp=0.5)*0.9

# Görsel (airy, A minor: Am C G Em)
def music_visual():
    Am=[57,60,64]; C=[60,64,67]; G=[55,59,62]; Em=[52,55,59]
    return music([Am,C,G,Em],bpm=72,pad_amp=0.4,arp_amp=0.55,arp_pattern=(0,2,1,2))*0.9

# Okuma (calm, C major: C Am F G) - softer, slower, less arp
def music_reading():
    C=[48,52,55]; Am=[45,48,52]; F=[41,45,48]; G=[43,47,50]
    m=music([C,Am,F,G],bpm=58,pad_amp=0.5,arp_amp=0.3,arp_pattern=(0,1,2,1))
    return m*0.85

save('sfx_correct', sfx_correct())
save('sfx_combo', sfx_combo())
save('sfx_wrong', sfx_wrong())
save('sfx_level', sfx_level())
save('sfx_achieve', sfx_achieve())
save('mus_word', music_word())
save('mus_visual', music_visual())
save('mus_reading', music_reading())
print('done')
