# https://youtu.be/ZxMB6Njs3ck
- github
  - https://github.com/SteinOveHelset/puddle
# ⌨️ (0:02:20) Setting up
- manage.py
  - 管理タスクを実行するための一種のスクリプト
- asgi.py, wsgi.py
  - Webサーバーのエントリポイント
    - プロジェクトをライブサーバーに配置する
- settings.py
  - プロジェクト全体の構成ファイル
# ⌨️ (0:06:00) First app
- core
  - admin.py
    - DBモデルを登録する
  - apps.py
    - このアプリケーション専用の構成ファイル
- djangoに使用しているアプリケーションを伝えることができる
  - settings.py
    - INSTALLED_APPSに追加
- 引数：request
  - リクエスト情報全般を取得
- templatesディレクトリ
  - Djangoはsettings.pyで登録したアプリケーション内のtemplatesを自動で参照する
- templateの継承
  - ページタイトルとかも動的に変化させられる
# ⌨️ (0:24:51) Items
- `python manage.py startapp item`
  - settings.pyのINSTALLED_APPSに追加する
- models.py
  - idは定義しなくても自動で作成される
- `python manage.py createsuperuser`
  - 管理者画面からデータの追加などを行える
    - name
      - admin
    - email
      - admin@email.com
    - pass
      - learn-django
- 管理者画面
  - モデルをadmin.pyに明示的に指定しないと管理者画面からデータの操作はできない
- Metaクラス
  - モデルの設定・オプションを記述するクラス
## モデルの複数形の自動補完が間違っている問題
- 状況
  - Categoryモデルを作成したところ，その複数形がCategorysになっており，綴りが間違えている
- 原因
  - Djangoは自動でモデル名の末尾にsを付けるから
- 解決策
  - models.py
```diff
class Category(models.Model):
    name = models.CharField(max_length=255)

+   class  Meta:
+       verbose_name_plural = 'Categories'
```
## モデル内のデータが分かりにくい表示になっている問題
- 状況
  - 管理画面のテーブル内のデータが`<model name> object (<num>)`という表示になってしまっている
- 原因
  - Djangoの初期設定
- 解決策
  - models.py
```diff
class Category(models.Model):
    name = models.CharField(max_length=255)

    class  Meta:
        verbose_name_plural = 'Categories'

+   def __str__(self):
+       return self.name
```
## DockerでPillowをインストールすると上手くインストールされない問題
- 状況
  - `docker exec -it learn-django-web-1 bash`
  - `pip install pillow`
  - 以下のエラーが発生
```
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
WARNING: You are using pip version 22.0.4; however, version 23.0.1 is available.
You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
```
- 原因
  - 不明
    - エラー文の通り見ると，Dockerコンテナ内でrootユーザーとしてpip installコマンドが実行されているため、パーミッションの問題やシステムパッケージマネージャとの競合が発生する可能性があることを警告しています。また、pipのバージョンが古いことも警告されています。
    - ただ，その対策（pipのアップデート及びrootユーザーからの切り替えをDockerfile内で実行）をしても，正常に動作しなかった
```diff
FROM python:3.9

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt /app/
+ RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . /app/

+ RUN useradd -m myuser
+ USER myuser
```
- 解決策
  - requirements.txtを編集
  - `docker-compose up -d --build`
```diff
Django==3.2.9
gunicorn==20.1.0
psycopg2-binary==2.9.1
+ Pillow==8.4.0
```
## マイグレーションをやり直そうとしたらエラーが発生する問題
- 状況
  - models.pyを編集
  - マイグレーションをし直すために，一つ前のマイグレーションファイルを削除
  - `docker exec -it learn-django-web-1 bash`
  - `cd myproject`
  - `python manage.py makemigrations`
  - `python manage.py migrate`
以下のエラーが発生
```
django.db.utils.OperationalError: table "item_item" already exists
```
- 原因
  - マイグレーションファイルを削除してしまったため，migrateコマンドの実行プロセスと実際のDBの状態に矛盾が生じたから
- 解決策
  - `docker-compose down`
  - `db.sqlite3`を削除
    - この時点でDBデータも消えてしまうので注意
    - 開発環境でのみ行える
  - `docker-compose up -d --build`
  - `docker exec -it learn-django-web-1 bash`
  - `cd myproject`
  - `python manage.py makemigrations`
  - `python manage.py migrate`
  - `python manage.py createsuperuser`
    - これもやり直さないといけない
## 保存した画像がうまく表示されない問題
- 状況
  - mediaディレクトリにもDBにも正常に保存されているのに，`item.image.url`で画像が表示されない
    - ローカルホスト自体にもアクセスできなくなった．
- 原因
  - Djangoの開発サーバーは、MEDIA_URLとMEDIA_ROOTで指定されたディレクトリの静的ファイルを自動的に提供しないため
- 解決策
  - 開発環境にいる間は以下のようにurls.pyを修正する
    - 本番環境ではこのやり方は推奨されておらず，Webサーバー（Nginx,Apacheなど）を使用して性的ファイルをアップロードされたファイルを提供することが推奨される
  - urls.py
```diff
from django.contrib import admin
from django.urls import path

+ from django.conf import settings
+ from django.conf.urls.static import static

from core.views import index, contact

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index, name='index'),
    path('contact/', contact, name='contact'),
- ]
+ ] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```
# ⌨️ (0:44:30) Item detail
- app_name
  - urls.pyに設定することで，`item:detail`のようなURLの名前をitemというapp_nameをもつ，urls.pyを参照するというように解決することができる
# ⌨️ (0:55:56) Signing up
- Djangoが用意しているUserモデルを使用する
# ⌨️ (1:15:44) Adding items
- templateはなるべく使いまわせるように工夫する
# ⌨️ (1:28:25) Dashboard
- `python manage.py startapp dashboard`
- アプリの分け方
  - 単一責任原則
    - 各アプリケーションは、一つの機能や目的に焦点を当てるべき
      - そうすることで，結合度を抑えられ，再利用性も上がる
    - URLで分けるというのもアリかも？
      - 親アプリのurls.pyにルートを書き込む際に綺麗に分かれる
        - item/
        - dashboard/
  - 具体例
    - 認証と認可
    - ブログ
    - コメント
    - 通知
# ⌨️ (1:40:01) Searching
## 選択したカテゴリーの色を変更できない問題
- 状況
  - カテゴリを選択
  - queryに載せてviewに渡す
  - category_idという名前で元のtemplateに返す
  - template上でcategory.idとcategory_idが一致するものの背景色を変更するifディレクティブを追加
  - しかし，色が反映されない
- 原因
  - category_idが文字列型で渡されていたこと
- 解決策
  - `myproject\item\views.py`
```diff
def items(request):
    query = request.GET.get('query', '') # 第2引数はデフォルト値
    category_id = request.GET.get('category', 0)
    categories = Category.objects.all()
    items = Item.objects.filter(is_sold=False)

    if query:
        items = items.filter(Q(name__icontains=query) | Q(description__icontains=query))

    return render(request, 'item/items.html', {
        'items': items,
        'query': query,
        'categories': categories,
-         'category_id': category_id,
+         'category_id': int(category_id),
    })
```
# ⌨️ (1:53:43) Communication
- `python manage.py startapp conversation`
- メッセージ作成までの流れ
  - detail.html `/items/<item_pk>/`
    - contact sender `{% url 'conversation:new' item.id %}`をクリック
  - `conversation/new.html`がレンダリング
    - Send `<form action="." method="post">`をクリック
      - `.`は現在のURL `/inbox/new/<item_pk>/`を指している
  - conversationsテーブルとconversationMessagesテーブルにデータを保存
  - detail.htmlへリダイレクト
- `conversations.first().id`でアクセスしなければならない理由
  - conversationsに入っているデータの型がQueryset型だから
    - ロジック的には単一のデータしか入らなくても，この取得方法でデータにアクセスしなければいけない
```diff
conversations = Conversation.objects.filter(item=item).filter(members__in=[request.user.id])

if conversations:
-    return redirect('conversation:detail', pk=conversations.id)
+    return redirect('conversation:detail', pk=conversations.first().id)
```
## .gitignoreの内容が反映されていない問題
- 状況
  - プロジェクトの途中で，gitignoreを作成していなかったことに気づき作成
  - しかし，その内容が反映されない
- 原因
  - 途中から.gitignoreを作成したため，指定したファイルが既にGitの管理対象に登録されてしまっていたから
- 解決策
  - `git rm -r --cached .`

---

# Tips
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
  - mobileフレンドリーにする設定
- `href="{% url 'contact' %}"`
  - urls.pyでname指定したルートを設置できる
- `form.save(commit=False)`
  - オブジェクトを作成するだけで、保存はしない
- .gitignoreファイルに含めるべきものたち
  - `__pycache__/`
    - インポートされたモジュールのバイトコードをキャッシュして、次回の実行時に高速に読み込むことができるようにします。
    - プロジェクトの機能や実行には直接関係がなく、実行環境に依存するファイルが格納されています。
  - `*.pyc`
    - 一時ファイル
  - `*.pyo`
    - 一時ファイル
  - `db.sqlite3`
    - 以下の理由からバージョン管理に含めない．開発者間でのDB情報の共有は，マイグレーションファイルやフィクスチャファイルを使用する
      - 開発者間でデータベースの状態が異なることがあるため
      - データベースのサイズが大きくなることがあるため
      - 機密情報の漏洩防止
  - `<model instance>.filter(<column name>__icontains=<query>)`
    - 特定のカラムのなかで大文字小文字を区別せずにquery文字列を含むデータ取得している
      - 複数カラムの検索条件を付与したい場合は`from django.db.models import Q`を利用すると簡単に書くことができる
      - 複数の条件を付与したいときは，同じオブジェクトにフィルタリングを繰り返す形で絞り込んでいけばよい
- ***startappをする度にsettings.pyに追記***
- ***モデルを作成したらadmin.pyに指定する***
- `related_name`オプション
  - リレーションの逆方向の関連を定義する 
    - 関連名をカスタマイズできる
      - 明示的になり，クエリなどもより簡素に記述することができる
- Messageモデル
  - django組み込みで持っているメッセージフレームワーク（通知機能を実装する用）はMessageモデルを使用するため，同じ名前にするとクラッシュしてしまう可能性があるのでConversationMessageモデルという名前で作成している
- `conversation.members.all`
  - ただ，`conversation.members`とするだけでは，会話のメンバーのオブジェクトは取得できない
    - これは，membersフィールドがManyToManyFieldとして定義されており、Djangoではこのタイプのフィールドに対して関連オブジェクトを取得するために、オブジェクト関連マネージャ（Object-Related Manager）を使用する必要があるから
- idとpkの使い分け
  - id
    - 各Djangoモデルに自動的に追加されるフィールド
    - 整数のオートインクリメントフィールド（AutoField）として設定され、各レコードに一意の識別子を提供します。
  - pk
    - モデルの主キーを参照するショートカット
    - モデルにおいて、主キーが明示的に定義されていない場合は id が主キーとして扱われます。
      - しかし、モデルにカスタム主キーが定義されている場合、pk はそのカスタム主キーを指します。
  - 使い分け
    - id を使うべき場合
      - モデルにデフォルトの id フィールドがあり、特定のレコードにアクセスしたい場合。
    - pk を使うべき場合
      - モデルがカスタム主キーを持っているかどうかに関わらず、一意の識別子を使用してレコードにアクセスしたい場合。
        - pk はモデルの主キーに関わらず一貫して動作するため、コードの可読性や保守性が向上します。
