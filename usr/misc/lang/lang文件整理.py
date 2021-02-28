import re

lang={} 

pattern=re.compile(r"(.*)=(.*)")

with open(input("输入:"),'r') as f:
    for i in f.readlines():
        match=pattern.match(i)
        if not match:
            continue
        lang[match.group(1)]=match.group(2)
with open(input("输出:"),'w') as f:
    for i in sorted(lang.keys()):
        f.write(i+"="+lang[i]+"\n")