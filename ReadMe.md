__**************************************************************************************__  
__*　Docker for Windows におけるLAPP環境構築__  
__**************************************************************************************__  
  
__**************************************************************************************__  
__*　ファイル構成__  
__**************************************************************************************__  

k8s-lampp-windows/  
　┣1.db-disk/・・・DBの永続ボリュームを作成するyaml等  
　┣2.src-deploy-disk/・・・srcの永続ボリュームを作成するyaml等  
　┣3.psql-rebuild/・・・postgreSQLのコンテナ、service、deployment等を作成するyaml等  
　┣4.mysql-rebuild/・・・MySQLのコンテナ、service、deployment等を作成するyaml等  
　┣5.dns/・・・DNS(bind)のコンテナ、service、deployment等を作成するyaml等  
　┣6.ingress/・・・ingressのyaml等  
　┣7.mailsv-rebuild/・・・postfixのコンテナ、service、deployment等を作成するyaml等  
　┣8.apache-rebuild/・・・apacheのコンテナ、service、deployment等を作成するyaml等  
　┣9.php5-rebuild/・・・php-fpm(php5)のコンテナ、service、deployment等を作成するyaml等  
　┣10.php7-rebuild/・・・php-fpm(php7)のコンテナ、service、deployment等を作成するyaml等  
　┣11.php8-rebuild/・・・php-fpm(php8)のコンテナ、service、deployment等を作成するyaml等  
　┣k8s-lampp-all-build.sh・・・k8s-lampp-windowsのk8sコンテナを一斉に作成するシェル  
　┣k8s-lampp-all-remove.sh・・・k8s-lampp-windowsのk8sコンテナを一斉に削除するシェル  
　┣kube-db-proxy.bat・・・podのDBへDBクライアント（A5等）から接続する為のポートフォワード起動  
　┣kubeproxy.bat・・・kubernetesダッシュボードへアクセスする為のproxyを実行するバッチ  
　┗ReadMe.md・・・使い方等々の説明  

__**************************************************************************************__  
__*　前提条件：この設定ファイルの環境要件__  
__**************************************************************************************__  

【環境要件】  
◆OS  
・Windows10 Pro(x64)  

◆ソフトウェア  
・minikube v1.23.0  
・Ubuntu 20.04 LTS(WSL2)（※１）（※３）  
・Kubernetes v1.22.1（※１）  
・skaffold 0.3.3 （※２）  

（※１）記載のバージョンでないと動作しない。インターネットで左記バージョンを入手するか、以下URLのものを使用する事。  
（※２）こちらも記載のバージョンでないと動作しない。skaffoldは以下コマンドでバージョン固定しているので、意識しなくてもこのバージョンが入ります。  
（※３）WSL2  

__**************************************************************************************__  
__*　kubernetesを動かす基盤となるソフトウェアのインストール（全てUbuntu 18.04 LTSで実施）__  
__*　※ 1回だけ実施すればよい。__  
__**************************************************************************************__  

#### # k8s-lampp-windowsのフォルダの中身を「C:\k8s\k8s-lampp-windows」へ配置する。

#### # WSLの設定をする

※WSL2になっているかを確認＆なっていなければ切替
以下でWSLのバージョンを確認する。
wsl -l -v
```
  NAME                   STATE           VERSION
* Ubuntu-20.04           Running         2
```
VERSIONが1になっている場合は以下コマンドで2にする。
「Ubuntu-20.04」は上記で表示されるNAMEに合わせて下さい。
```
wsl --set-default-version 2
wsl --set-version Ubuntu-20.04 2
```
設定が完了したら以下コマンドをコマンドプロンプトで実行。
```
 wsl --shutdown
```
以下コマンドをWSLで実行し、「5.10.16.3-microsoft-standard-WSL2」と出れば設定完了。
```
$ uname -r
5.10.16.3-microsoft-standard-WSL2
```

※Windowsボタン＋Ctrlで開く「ファイル名を指定して実行」で「%USERPROFILE%」と入力してエンター押下。開いたWindowsエクスプローラーで「.wslconfig」というファイルを作成し、以下の内容を記載する。
```
[wsl2]
processors=2
memory=3500MB
swap=0
```
  
##### # Dockerインストール＆自動起動設定
curl https://get.docker.com | sh  
  
sudo visudo  
##### # 以下を追記。[ユーザーID]には自分のユーザ名を入れること  
```
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/sbin/service docker start
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/sbin/service docker stop
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/bin/mkdir /mnt/k8s
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/bin/mount --bind /var/lib/docker/volumes/minikube/_data/lib/k8s /mnt/k8s
```
  
##### # Minikubeインストール  
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
minikube start --driver=docker --kubernetes-version=v1.22.1 --memory='3g' --cpus=2
  
vim ~/.bash_profile
##### # 以下を追記して、WSL再起動  
```
/mnt/c/k8s/k8s-lampp-windows/minikube-start.sh
```
  
##### # Ingressアドオン有効化  
minikube addons enable ingress  
※WindowsのブラウザからコンテナのWebサーバーへアクセスするには、「ingressproxy.bat」の実行が必要 

#### # WSLでskaffoldインストール
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v0.33.0/skaffold-linux-amd64  
sudo chmod +x skaffold  
sudo mv skaffold /usr/local/bin  
  
#### # WSL(Bash on Windows)でDockerを使用する
##### ＜参考＞
##### # https://qiita.com/yoichiwo7/items/0b2aaa3a8c26ce8e87fe
##### # https://medium.com/@XanderGrzy/developing-for-docker-kubernetes-with-windows-wsl-9d6814759e9f
##### # https://www.myzkstr.com/archives/888

#### # Dockerインストール (Communityエディション)  
sudo apt install apt-transport-https ca-certificates curl software-properties-common  
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"  
sudo apt update  
sudo apt install docker-ce  
  
#### # kuberctlインストール  
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -   
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list  
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni  

#### # Windowsエクスプローラーからコンテナがマウントする永続ボリュームへ書き込み・参照する為の設定  
※Windowsキー＋Ctrlで開く「ファイル名を指定して実行」ダイアログで以下を入力してエンターで、  
　Dockerのファイルシステムを閲覧、書き込みが可能となる  
　（ただし、ownerをwww-data:www-dataにするか、777でフル権限を与える必要あり）  
　（一度以下「kubernetesでLAPP環境構築する手順」以降を実行して環境が出来てからWSL再起動が必要）  
\\wsl$\mnt\k8s  
  
#### # DockerのDNS設定  
sudo vi /etc/init.d/docker
##### # DOCKER_OPTS=を以下のように修正
DOCKER_OPTS="--dns 8.8.8.8"
※設定後「minikube-restart.bat」を実行してdocker、minikubeを再起動。
  
# Windowsエクスプローラーからコンテナがマウントする永続ボリュームへ書き込み・参照したい時のパス  
「\\wsl$\Ubuntu-20.04」をネットワークドライブZへマウントする。  
  
#### sshの鍵登録 ※要事前に2.src-deploy-disk/ssh-keysへSSHの鍵配備
2.src-deploy-disk/ssh-keys配下に、「id_rsa」と、「id_rsa.pub」を配備しておく。例えば以下。  
cd /mnt/c/k8s/k8s-lampp-windows/2.src-deploy-disk/ssh-keys  
ssh-keygen -t rsa  
cp -a ~/.ssh/id_rsa* ./  
  
__**************************************************************************************__  
__*　kubernetesでLAPP環境構築する手順__  
__*　※ 1回だけ実施すれば良い。__  
__*　kubernetesの環境を作り直したい場合は以下で作成した環境を一度削除し、__  
__*　もう一度実施する事も可能。phpのpodだけ削除して作り直すことも可能だし、__  
__*　skaffoldを使っている箇所は設定を変更してskaffold_run.shを実行するだけで反映される。__  
__**************************************************************************************__  

__*******************************************__  
__*　スクリプトで実行する場合__  
__*******************************************__  
cd /mnt/c/k8s/k8s-lampp-windows  
./k8s-lampp-all-build.sh  

__※スクリプトで実行する場合は、以下「手動で実行する場合」は実施不要__

__*******************************************__  
__*　手動で実行する場合__  
__*******************************************__  

#### # クラスタの確認
kubectl config get-clusters  

#### # コンテキストの確認
kubectl config get-contexts  

#### # コンテキストの向き先確認
kubectl config current-context  

#### # namespace作成
kubectl create namespace k8s-lampp-windows  

#### # namespace確認
kubectl get namespace  

#### # namespace切り替え
kubectl config current-context  
##### # 上記コマンドで表示されたコンテキスト名を、以下のコマンドset-contextの次に組み込む。  
##### # namespaceには、切り替えたいnamespaceを設定する。  
kubectl config set-context minikube --namespace=k8s-lampp-windows  

#### # コンテキストの向き先確認
kubectl config get-contexts  

#### ＜DBのpvc構築＞
##### ＜参考＞
##### # https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/  
##### # https://systemkd.blogspot.com/2018/02/docker-for-mac-kubernetes-ec-cube_12.html  

#### # PersistentVolumeClaimの構築
cd /mnt/c/k8s/k8s-lampp-windows/1.db-disk  
kubectl apply -f 1.PersistentVolume.yaml  
kubectl apply -f 2.PersistentVolumeClaim.yaml  

#### # PersistentVolumeが作成されているかを確認
kubectl get pv  

#### # PersistentVolumeClaimが作成されているかを確認
kubectl get pvc  

#### # secretの作成
##### # キーの作成は以下のようにして行う
##### # echo -n "database_user" | base64
##### # echo -n "database_password" | base64
##### # echo -n "secret_key_base" | base64
kubectl apply -f 3.php-apache-psql-secret.yaml  

#### # pod一覧
kubectl get pod  

#### ＜src-deployのpvc構築＞
cd /mnt/c/k8s/k8s-lampp-windows/2.src-deploy-disk  

#### # PersistentVolumeの構築
kubectl apply -f 1.PersistentVolume.yaml  

#### # PersistentVolumeClaimの構築
kubectl apply -f 2.PersistentVolumeClaim.yaml  

#### # PersistentVolumeが作成されているかを確認
kubectl get pv  
 または  
kubectl -n k8s-lampp-windows get pv  

#### # PersistentVolumeClaimが作成されているかを確認
kubectl get pvc  
 または  
kubectl -n k8s-lampp-windows get pvc  

#### # 全イメージを表示する．
docker images  

#### sshの鍵登録 ※要事前に2.src-deploy-disk/ssh-keysへSSHの鍵配備
kubectl create secret generic ssh-keys --from-file=./ssh-keys/id_rsa --from-file=./ssh-keys/id_rsa.pub  

#### ＜postgreSQL構築＞
##### # postgreSQLイメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/3.psql-rebuild  
./skaffold_run.sh  

#### ＜MySQL構築＞
##### # MySQLイメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/4.mysql-rebuild  
./skaffold_run.sh  

#### ＜DNS(bind)構築＞
##### # DNS(bind)イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/5.dns  
./skaffold_run.sh  

#### ＜ingressを構築＞
#### sslの鍵登録 ※HTTPSを使用する際は実施
##### # kubectl create secret tls example1.co.jp --key ../8.apache-rebuild/ssl/example1.co.jp/svrkey-sample-empty.key --cert ../8.apache-rebuild/ssl/example1.co.jp/svrkey-sample-empty.crt

#### # Ingressの作成
kubectl apply -f 80.ingress.yaml  

#### # ingressに割り振られたグローバルアドレスの確認
kubectl get ingress  

#### ＜mailsv構築＞
##### # mailsvイメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/7.mailsv-rebuild  
kubectl apply -f ./k8s-mailsv-sv.yaml  

#### ＜apache構築＞
##### # apacheイメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/8.apache-rebuild
./skaffold_run.sh  

#### ＜php構築＞
##### # php5イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/9.php5-rebuild
./skaffold_run.sh  

###### # ＜php5で動作するプロジェクトのソースのチェックアウト＞
kubectl exec -it `kubectl get pod -n k8s-lampp-windows | grep php5-fpm | grep Running | awk -F " " '{print $1}'` /bin/bash -n k8s-lampp-windows  
cd /mnt/src
mkdir ./[プロジェクトのディレクトリ名]
cd ./[プロジェクトのディレクトリ名]
git clone [gitのリポジトリURL] .

##### # php7イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/10.php7-rebuild
./skaffold_run.sh  

###### # ＜php7で動作するプロジェクトのソースのチェックアウト＞
kubectl exec -it `kubectl get pod -n k8s-lampp-windows | grep php7-fpm | grep Running | awk -F " " '{print $1}'` /bin/bash -n k8s-lampp-windows  
cd /mnt/src
mkdir ./[プロジェクトのディレクトリ名]
cd ./[プロジェクトのディレクトリ名]
git clone [gitのリポジトリURL] .

##### # php8イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/11.php8-rebuild
./skaffold_run.sh  

###### # ＜php8で動作するプロジェクトのソースのチェックアウト＞
kubectl exec -it `kubectl get pod -n k8s-lampp-windows | grep php8-fpm | grep Running | awk -F " " '{print $1}'` /bin/bash -n k8s-lampp-windows  
cd /mnt/src
mkdir ./[プロジェクトのディレクトリ名]
cd ./[プロジェクトのディレクトリ名]
git clone [gitのリポジトリURL] .


__**************************************************************************************__  
__*　以下はkubernetesを操作する際によく使うコマンド__  
__**************************************************************************************__  

#### # k8s-lampp-windowsをネームスペースごとすべて削除
./k8s-lampp-all-remove.sh

#### # namespace切り替え
kubectl config current-context  
#### # 上記コマンドで表示されたコンテキスト名を、以下のコマンドに組み込む
kubectl config set-context minikube --namespace=k8s-lampp-windows  

#### # コンテキストの向き先確認
kubectl config get-contexts -n k8s-lampp-windows  

#### # pod一覧
kubectl get pod -n k8s-lampp-windows  

#### # init-data.shの実行
##### # init-data.shはpod起動時に自動で実行される。pod稼働中に必要になった場合に以下を実行する。
kubectl exec -it [podの名称] /bin/bash  
kubectl exec -it `kubectl get pod -n k8s-lampp-windows | grep php7-fpm | grep Running | awk -F " " '{print $1}'` /bin/bash -n k8s-lampp-windows  
kubectl exec -it `kubectl get pod -n k8s-lampp-windows | grep apache | awk -F " " '{print $1}'` /bin/bash -n k8s-lampp-windows  
kubectl exec -it postgresql-0 /bin/bash  
kubectl exec -it postfix-77d69ff664-5drvf /bin/bash  
kubectl exec -it dns-6b8bb6b759-rkn25 /bin/bash 
kubectl exec -it mysql-0 /bin/bash -n k8s-lampp-windows  
kubectl exec -it php5-fpm-7d56f8dc44-rr5jw /bin/bash  


#### # ポートフォワード（postgreSQLへの接続時等に使用）
kubectl port-forward postgresql-0 5432:5432  


__**************************************************************************************__  
__*　トラブルシューティング__  
__**************************************************************************************__  

#### # skaffold_run.shで以下エラーが出た場合  
```
FATA[0001] failed to build: build failed: building [php5-gke-php]: build artifact: docker build: error during connect: Post https://127.0.0.1:49156/v1.38/build?buildargs=null&cachefrom=null&cgroupparent=&cpuperiod=0&cpuquota=0&cpusetcpus=&cpusetmems=&cpushares=0&dockerfile=Dockerfile&forcerm=1&labels=null&memory=0&memswap=0&networkmode=&rm=0&shmsize=0&t=php5-gke-php%3Adirty&target=&ulimits=null: creating docker context: getting relative tar paths: expanding ONBUILD instructions: parsing ONBUILD instructions: processing base image (centos:centos7) for ONBUILD triggers: getting remote config: getting image: Get https://auth.docker.io/token?scope=repository%3Alibrary%2Fcentos%3Apull&service=registry.docker.io: invoking docker-credential-desktop.exe: exec: "docker-credential-desktop.exe": executable file not found in $PATH; output:
```
vi ~/.docker/config.json
`"credsStore": "desktop.exe"`の`credsStore`を`credStore`へ変更して保存すればなおる