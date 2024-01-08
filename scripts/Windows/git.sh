## 删除远程分支
#分支切换到master分支
git checkout master
#删除远程不再使用的分支
git push origin --delete [废弃分支名称]

## 拉取指定commitid代码
#从远程分支 clone 到本地新建文件夹。使用：
git clone [git-url] -b [branch-name]
#指定 commit 版本。使用：
git reset --hard [commit-number]
#推送到远程（新建）分支
git push origin [本地分支]:[远程分支名称]




#gitee图床链接格式
![image-20220905194115105](https://gitee.com/kangyao59/blogimg/raw/master/img/image-20220905194115105.png)

git status;git add .;git status;git commit -m "add data";git push;git status

git clone -b yaokang https://gitee.com/lizhuo9527/knowledge-hub.git



https://github.com/frank-kahn/SQL-DEV.git

echo "# SQL-DEV" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/frank-kahn/SQL-DEV.git
git push -u origin main

git remote add origin https://github.com/frank-kahn/SQL-DEV.git
git branch -M main
git push -u origin main



git status;git add .;git status;git commit -m "add data";git push;git status