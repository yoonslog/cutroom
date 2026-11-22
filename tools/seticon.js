// usage: node seticon.js in.exe icon.ico out.exe
const fs=require('fs'),ResEdit=require('resedit'),PE=require('pe-library');
const [,,inp,ico,out]=process.argv;
const exe=PE.NtExecutable.from(fs.readFileSync(inp),{ignoreCert:true});
const res=PE.NtExecutableResource.from(exe);
const iconFile=ResEdit.Data.IconFile.from(fs.readFileSync(ico));
const groups=ResEdit.Resource.IconGroupEntry.fromEntries(res.entries);
const id=groups.length?groups[0].id:1,lang=groups.length?groups[0].lang:1033;
ResEdit.Resource.IconGroupEntry.replaceIconsForResource(res.entries,id,lang,iconFile.icons.map(i=>i.data));
const vi=ResEdit.Resource.VersionInfo.fromEntries(res.entries);
if(vi.length){const v=vi[0];const langs=v.getAllLanguagesForStringValues();
  for(const l of langs)v.setStringValues(l,{ProductName:'Velo',FileDescription:'Velo 영상 편집기',InternalName:'Velo',OriginalFilename:'Velo.exe',CompanyName:'Velo',SpecialBuild:'Velo'});
  v.outputToResourceEntries(res.entries);}
res.outputResource(exe);fs.writeFileSync(out,Buffer.from(exe.generate()));
console.log('icon set',id,lang,'versioninfo',vi.length);
