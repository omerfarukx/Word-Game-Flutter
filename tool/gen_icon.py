from PIL import Image, ImageDraw, ImageFont
import os

S=512
img=Image.new('RGBA',(S,S),(0,0,0,0))
# gradient violet->indigo diagonal
top=(165,133,255); bot=(109,84,240)
grad=Image.new('RGB',(S,S))
gd=grad.load()
for y in range(S):
    for x in range(S):
        t=(x+y)/(2*S)
        gd[x,y]=tuple(int(top[i]*(1-t)+bot[i]*t) for i in range(3))
# rounded mask
mask=Image.new('L',(S,S),0)
md=ImageDraw.Draw(mask)
r=int(S*0.23)
md.rounded_rectangle([0,0,S,S],radius=r,fill=255)
img.paste(grad,(0,0),mask)
d=ImageDraw.Draw(img)
# soft top highlight
hl=Image.new('RGBA',(S,S),(0,0,0,0))
hd=ImageDraw.Draw(hl)
hd.rounded_rectangle([0,0,S,int(S*0.5)],radius=r,fill=(255,255,255,28))
img=Image.alpha_composite(img, Image.composite(hl, Image.new('RGBA',(S,S),(0,0,0,0)), mask))
d=ImageDraw.Draw(img)
# letter K
fp=None
for c in ['C:/Windows/Fonts/arialbd.ttf','C:/Windows/Fonts/Arial.ttf']:
    if os.path.exists(c): fp=c; break
font=ImageFont.truetype(fp, int(S*0.62)) if fp else ImageFont.load_default()
tw=d.textbbox((0,0),'K',font=font)
w=tw[2]-tw[0]; h=tw[3]-tw[1]
# subtle shadow then white
d.text(((S-w)/2-tw[0], (S-h)/2-tw[1]+6), 'K', font=font, fill=(40,20,90,120))
d.text(((S-w)/2-tw[0], (S-h)/2-tw[1]), 'K', font=font, fill=(255,255,255,255))

sizes={'mdpi':48,'hdpi':72,'xhdpi':96,'xxhdpi':144,'xxxhdpi':192}
base="C:/Flutter/Word-Game-Flutter/android/app/src/main/res"
for d_,px in sizes.items():
    out=img.resize((px,px),Image.LANCZOS)
    p=os.path.join(base,f"mipmap-{d_}")
    for name in ['ic_launcher.png','ic_launcher_round.png']:
        fp2=os.path.join(p,name)
        out.save(fp2)
# also save a 512 master for stores
img.save("C:/Flutter/Word-Game-Flutter/assets/images/app_icon.png")
print("icons written")
