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
・Ubuntu 20.04 LTS(WSL2)  
・Kubernetes v1.22.1
  
__**************************************************************************************__  
__*　kubernetesを動かす基盤となるソフトウェアのインストール（全てUbuntu 18.04 LTSで実施）__  
__*　※ 1回だけ実施すればよい。__  
__**************************************************************************************__  

#### # k8s-lampp-windowsのフォルダの中身を「C:\k8s\k8s-lampp-windows」へ配置する。

##### # Dockerインストール＆自動起動設定
https://get.docker.com | sh  
  
sudo visudo  
##### # 以下を追記。[ユーザーID]には自分のユーザ名を入れること  
```
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/sbin/service docker start
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/sbin/service docker stop
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/bin/mkdir /mnt/k8s
[ユーザーID] ALL=(ALL:ALL) NOPASSWD: /usr/bin/mount --bind /var/lib/docker/volumes/minikube/_data/lib/k8s /mnt/k8s
```
  
vim ~/.bash_profile
##### # 以下を追記して、WSL再起動  
```
echo $(service docker status | awk '{print $4}') #起動状態を表示
if test $(service docker status | awk '{print $4}') = 'not'; then #停止状態
  sudo /usr/sbin/service docker start #起動
fi
```
  
##### # Minikubeインストール  
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
  
vim ~/.bash_profile
##### # 以下を追記して、WSL再起動  
```
MINIKUBE=`minikube status 2>&1 | grep -e "Stopped" -e "Nonexistent"` #起動状態を表示
echo $MINIKUBE
if [ -n "$MINIKUBE" ]; then #停止状態
  minikube start --driver=docker --kubernetes-version=v1.22.1 --memory='4g' --cpus=4 #起動
fi

# WindowsのホストIP登録
HOSTS=`minikube ssh "cat /etc/hosts" | grep host.docker.internal`
echo $HOSTS
if [ -z "$HOSTS" ]; then
        export winhost=$(cat /etc/hosts | grep host.docker.internal | awk '{ print $1 }')
        minikube ssh "sudo su - -c 'echo \"$winhost host.docker.internal\" >> /etc/hosts'"
fi
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
  
#### # Windowsエクスプローラーからコンテナがマウントする永続ボリューム（docker-desktop Distroのディレクトリ）へ書き込み・参照したい時のパス  
##### # 以下コマンドを実行し、DockerのファイルシステムをWSLへマウント
vim ~/.bash_profile
##### # 以下を追記して、WSL再起動  
```
if [ ! -e /mnt/k8s ] ; then
  sudo mkdir /mnt/k8s
fi
mountpoint -q /mnt/k8s
if [ ! $? -eq 0 ] ; then
  sudo mount --bind /var/lib/docker/volumes/minikube/_data/lib/k8s /mnt/k8s
fi
```
※Windowsキー＋Ctrlで開く「ファイル名を指定して実行」ダイアログで以下を入力してエンターで、  
　Dockerのファイルシステムを閲覧、書き込みが可能となる  
　（ただし、ownerをwww-data:www-dataにするか、777でフル権限を与える必要あり）  
\\wsl$\mnt\k8s  
  
#### # DockerのDNS設定  
sudo vi /etc/init.d/docker
##### # DOCKER_OPTS=を以下のように修正
DOCKER_OPTS="--dns 8.8.8.8"
※設定後「minikube-restart.bat」を実行してdocker、minikubeを再起動。

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

#### sshの鍵登録 ※要事前に2.src-deploy-disk\ssh-keysへSSHの鍵配備
kubectl create secret generic ssh-keys --from-file=./ssh-keys/id_rsa --from-file=./ssh-keys/id_rsa.pub  

#### ＜php-srcのボリュームへチェックアウト＞
##### # /mnt/c/k8s/k8s-lampp-windows/2.src-deploy-disk\storage
##### # ※ ここで各プロジェクトのソースコードをチェックアウトする

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
#### # Ingress Controllerの作成
##### # 参考サイト：https://kubernetes.github.io/ingress-nginx/deploy/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/cloud/deploy.yaml
cd /mnt/c/k8s/k8s-lampp-windows/6.ingress  


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

##### # php7イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/10.php7-rebuild
./skaffold_run.sh  

##### # php8イメージビルド
cd /mnt/c/k8s/k8s-lampp-windows/11.php8-rebuild
./skaffold_run.sh  

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
kubectl exec -it php5-fpm-7d8bc98989-wj8sp /bin/bash -n k8s-lampp-windows  
kubectl exec -it php7-fpm-54b77dc466-ks6lh /bin/bash -n k8s-lampp-windows  
kubectl exec -it php8-fpm-5458f6655-dhhq4 /bin/bash -n k8s-lampp-windows  
kubectl exec -it apache-97c76855-l2rzs /bin/bash -n k8s-lampp-windows  
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
