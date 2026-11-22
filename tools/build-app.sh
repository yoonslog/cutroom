#!/bin/bash
export LANG=C.UTF-8 LC_ALL=C.UTF-8
# Velo Windows 앱 빌드: update/resources.neu, download/Velo-Windows.zip, download/Velo-Setup.exe
# 필요: node, npx(@electron/asar), python3+PIL, makensis, /tmp/rs(resedit,pe-library)
set -e
VER=$(grep -oP "VELO_VERSION='\K[^']+" app/index.html)
ROOT=$(pwd); W=/tmp/velo-build; rm -rf $W; mkdir -p $W
npx -y @electron/asar extract update/resources.neu $W/ex
# 앱 화면: 웹용 스크립트 태그를 앱용(로컬 파일)으로 바꾼다
python3 - "$W/ex/resources/index.html" <<'PY'
import sys;src=open('app/index.html',encoding='utf-8').read()
a='<script src="../fb-config.js"></script>\n<script>window.CUTROOM_WEB=true;</script>\n<script src="https://cdn.jsdelivr.net/npm/peerjs@1.5.4/dist/peerjs.min.js"></script>'
assert src.count(a)==1,'script tags changed'
src=src.replace(a,'<script src="js/neutralino.js"></script>\n<script src="js/peerjs.min.js"></script>\n<script src="fb-config.js"></script>')
open(sys.argv[1],'w',encoding='utf-8').write(src)
PY
cp app/favicon.png app/logo.png $W/ex/resources/; cp app/logo.png $W/ex/resources/icons/appIcon.png
cp fb-config.js $W/ex/resources/fb-config.js 2>/dev/null || true
python3 - "$W/ex/neutralino.config.json" "$VER" <<'PY'
import json,sys;p=sys.argv[1];c=json.load(open(p))
c['applicationId']='kr.cutroom.app';c['version']=sys.argv[2]
w=c['modes']['window'];w['title']='Velo';w['icon']='/resources/icons/appIcon.png';w['exitProcessOnClose']=True
c['cli']['binaryName']='Velo'
json.dump(c,open(p,'w'),indent=2,ensure_ascii=False)
PY
npx -y @electron/asar pack $W/ex update/resources.neu
# 실행 파일 + 아이콘
python3 -c "
from PIL import Image
Image.open('app/logo.png').convert('RGBA').save('$W/Velo.ico',sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])"
node /tmp/rs/seticon.js installer/base.exe $W/Velo.ico $W/Velo.exe
mkdir -p $W/Velo; cp $W/Velo.exe update/resources.neu $W/Velo/; cp $W/Velo.ico $W/Velo/Velo.ico
sed "s/{VER}/$VER/" installer/README-first.txt > $W/Velo/읽어주세요.txt
rm -f download/Velo-Windows.zip; (cd $W && zip -qr $ROOT/download/Velo-Windows.zip Velo)
cp $W/Velo/읽어주세요.txt $W/Velo/README-first.txt
makensis -V2 -DOUTFILE=$ROOT/download/Velo-Setup.exe -DICONFILE=$W/Velo.ico -DSRCDIR=$W/Velo -DAPPVER=$VER installer/velo.nsi
# 예전 주소로 받는 사람도 새 파일을 받도록 같은 파일을 옛 이름으로도 둔다
cp download/Velo-Setup.exe download/CutRoom-Setup.exe; cp download/Velo-Windows.zip download/CutRoom-Windows.zip
echo "built v$VER"; ls -la download update/resources.neu
