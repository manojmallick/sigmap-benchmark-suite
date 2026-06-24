#!/usr/bin/env node
// Re-detect each ~/results/raw/<repo> language from ~/repos using the true
import {readdirSync,readFileSync,writeFileSync,existsSync} from 'fs';
import {join} from 'path';
const RAW=join(process.env.HOME,'results/raw'), REPOS=join(process.env.HOME,'repos');
const SUP={ts:'TypeScript',tsx:'TypeScript',js:'JavaScript',jsx:'JavaScript',mjs:'JavaScript',cjs:'JavaScript',py:'Python',java:'Java',kt:'Kotlin',kts:'Kotlin',go:'Go',rs:'Rust',cs:'CSharp',rb:'Ruby',php:'PHP',swift:'Swift',dart:'Dart',scala:'Scala',vue:'Vue',svelte:'Svelte'};
const UNSUP=new Set(['hs','clj','cljc','cljs','lua','c','h','cpp','cc','hpp','ex','exs','erl','ml','jl','r','pl']);
const SKIP=/(^|\/)(node_modules|\.git|dist|build|out|target|vendor)(\/|$)/;
function detect(dir){const c={};
  const walk=(d,rel='')=>{let es;try{es=readdirSync(d,{withFileTypes:true})}catch{return}
    for(const e of es){const r=rel?rel+'/'+e.name:e.name; if(SKIP.test('/'+r))continue;
      if(e.isDirectory())walk(join(d,e.name),r);
      else{const m=e.name.toLowerCase().match(/\.([a-z0-9]+)$/); if(m){const x=m[1]; if(SUP[x]||UNSUP.has(x))c[x]=(c[x]||0)+1;}}}};
  walk(dir);
  const top=Object.entries(c).sort((a,b)=>b[1]-a[1])[0];
  return top? (SUP[top[0]]||'Unknown') : 'Unknown';}
let changed=0;
for(const name of readdirSync(RAW)){
  const meta=join(RAW,name,'meta.json'); const repo=join(REPOS,name);
  if(!existsSync(meta)||!existsSync(repo))continue;
  const m=JSON.parse(readFileSync(meta)); const lang=detect(repo);
  if(m.language!==lang){console.log(`  ${name}: ${m.language} -> ${lang}`); m.language=lang; writeFileSync(meta,JSON.stringify(m)); changed++;}
}
console.log('relabeled',changed,'repos');
