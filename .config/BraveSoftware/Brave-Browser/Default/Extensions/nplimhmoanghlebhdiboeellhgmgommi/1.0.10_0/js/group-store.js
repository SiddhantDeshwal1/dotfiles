class GroupStore{static snapshotGroup(a){return new Promise(function(b,c){chrome.tabGroups.get(a,function(d){d?chrome.tabs.query({windowId:chrome.windows.WINDOW_ID_CURRENT},async function(g){g=g.filter(f=>f.groupId===a&&f.url);await GroupStore.saveGroup(d,g);b(!0)}):b(!1)})})}static saveGroup(a,b){return new Promise(function(c,d){d=b.map(k=>({title:k.title,url:k.url,favIconUrl:k.favIconUrl}));const g=Date.now(),f=`group-${g.toString(36)}`,e=a.title??"",h={};h[f]={id:f,type:"group",createTime:g,title:e,
color:a.color,tabs:d};chrome.storage.local.set(h,function(){e?chrome.storage.local.get(null,async function(k){let m=[];for(var l of Object.values(k))"group"===l.type&&l.title===e&&m.push(l);m.sort((n,p)=>p.createTime-n.createTime);"function"===typeof SavedGroup?k=SavedGroup.maxSnapshots:(await InitPromise,k=MaxSnapshots);for(l=0;l<m.length;l++)l>=k&&await GroupStore.delete(m[l].id);c()}):c()})})}static snapshotTab(a){return new Promise(function(b,c){chrome.tabs.get(a,async function(d){d&&d.url?(await GroupStore.saveTab(d),
b(!0)):b(!1)})})}static saveTab(a){return new Promise(function(b,c){c=Date.now();const d=`tab-${c.toString(36)}`,g=a.url,f={};f[d]={id:d,type:"tab",createTime:c,title:a.title??"",url:g,favIconUrl:a.favIconUrl};chrome.storage.local.set(f,function(){chrome.storage.local.get(null,async function(e){let h=[];for(let k of Object.values(e))"tab"===k.type&&k.url===g&&h.push(k);h.sort((k,m)=>m.createTime-k.createTime);for(e=0;e<h.length;e++)1<=e&&await GroupStore.delete(h[e].id);b()})})})}static deleteTabInGroup(a,
b,c){return new Promise(function(d,g){chrome.storage.local.get(a,function(f){if((f=f[a])&&f.tabs[b]&&f.tabs[b].url===c){f.tabs.splice(b,1);let e={};e[a]=f;chrome.storage.local.set(e,function(){d(!0)})}else d(!1)})})}static addTabsInGroup(a,b){return new Promise(function(c,d){chrome.storage.local.get(a,function(g){let f=g[a];f&&f.tabs?(f.tabs=f.tabs.concat(b),chrome.storage.local.set(g,function(){c(!0)})):c(!1)})})}static delete(a){return new Promise(function(b,c){chrome.storage.local.remove(a,b)})}static updateGroup(a,
b,c){return new Promise(function(d,g){a.startsWith("group-")?chrome.storage.local.get(a,function(f){let e=f[a];e?(e[b]=c,chrome.storage.local.set(f,function(){d(!0)})):d(!1)}):d(!1)})}static updateGroupName(a,b){return GroupStore.updateGroup(a,"title",b)}static updateGroupColor(a,b){return GroupStore.updateGroup(a,"color",b)}static getAll(a){return new Promise(function(b,c){chrome.storage.local.get(null,function(d){d=Object.values(d);if("nameAsc"===a){let g=new Intl.Collator;d.sort((f,e)=>g.compare(f.title,
e.title))}else if("nameDesc"===a){let g=new Intl.Collator;d.sort((f,e)=>g.compare(e.title,f.title))}else"timeAsc"===a?d.sort((g,f)=>g.createTime-f.createTime):d.sort((g,f)=>f.createTime-g.createTime);b(d)})})}static deleteAll(){return new Promise(function(a,b){chrome.storage.local.clear(a)})}static mergeGroup(a){return a?new Promise(async function(b,c){var d=await GroupStore.getAll();const g=new Set;c=[];const f=[];for(var e of d)if("group"===e.type&&e.title===a){f.push(e);for(var h of e.tabs)g.has(h.url)||
(g.add(h.url),c.push(h))}if(1<f.length&&0<c.length){e=Date.now();h=`group-${e.toString(36)}`;d={};d[h]={id:h,type:"group",createTime:e,title:a,color:f[0].color,tabs:c};for(let k of f)await GroupStore.delete(k.id);chrome.storage.local.set(d,function(){b(!0)})}else b(!1)}):!1}static async mergeAllGroups(){var a=await GroupStore.getAll();let b=new Map;for(var c of a)"group"===c.type&&c.title&&(a=b.get(c.title)??0,b.set(c.title,a+1));c=!1;for(let [d,g]of b)1<g&&(await GroupStore.mergeGroup(d),c=!0);return c}static updateTab(a,
b,c){return new Promise(function(d,g){chrome.storage.local.get(a,function(f){let e=f[a];e&&"tab"==e.type?(e.title=b,e.url=c,chrome.storage.local.set(f,function(){d(e)})):d(!1)})})}static updateTabInGroup(a,b,c,d){return new Promise(function(g,f){chrome.storage.local.get(a,function(e){let h=e[a];if(!h||!h.tabs||b>=h.tabs.length)g(!1);else{let k=h.tabs[b];k.title=c;k.url=d;chrome.storage.local.set(e,function(){g(h)})}})})}static importJson(a){return new Promise(async function(b,c){let d;try{d=JSON.parse(await a.text())}catch(f){c("JSON parse failed");
return}if("tab-groups"==d.meta?.name&&1<=d.meta?.version){delete d.meta;var g={};for(const [f,e]of Object.entries(d)){if("group"===e.type){if(!e.tabs||!e.color)continue}else if("tab"===e.type){if(!e.url)continue}else continue;g[f]=e}chrome.storage.local.set(g,function(){chrome.runtime.lastError?c("storage save failed"):b()})}else c("metadata validation failed")})}static downloadFile(a,b){var c=new Date;const d=c.getFullYear(),g=`${c.getMonth()+1}`.padStart(2,"0");c=`${c.getDate()}`.padStart(2,"0");
b=`tabgroups_data_${d}${g}${c}.${b}`;GroupStore.exportFile||(GroupStore.exportFile=document.createElement("a"));GroupStore.exportFile.download=b;GroupStore.exportFile.href=a;GroupStore.exportFile.click()}static exportJson(){chrome.storage.local.get(null,function(a){a.meta={name:"tab-groups",version:1};a="data:application/json;charset=utf-8,"+encodeURIComponent(JSON.stringify(a));GroupStore.downloadFile(a,"json")})}static generateLi(a,b){b=b.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,
"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#039;");return`<li><a href="${a}">${b}</a></li>`}static async exportHtml(){var a=await GroupStore.getAll();const b=["<ul>"];for(let c of a)if("group"===c.type){b.push(`<li>\u25BC ${c.title?c.title:"No Name Group"}<ul>`);for(let d of c.tabs)b.push(GroupStore.generateLi(d.url,d.title));b.push("</ul></li>")}else"tab"===c.type&&b.push(GroupStore.generateLi(c.url,c.title));b.push("</ul>");a=`<!DOCTYPE html><html><head><meta charset="utf-8"><title></title><style>li{line-height:1.5;font-family:system-ui;} body>ul{list-style: none;}</style></head><body>${b.join("")}</body></html>`;
a="data:text/html;charset=utf-8,"+encodeURIComponent(a);GroupStore.downloadFile(a,"html")}};