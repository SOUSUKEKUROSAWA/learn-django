# Pythonイメージをベースにする
FROM python:3.9

# 環境変数を設定
ENV PYTHONUNBUFFERED 1

# 作業ディレクトリを作成・設定
RUN mkdir /code
WORKDIR /code

# 依存関係をコピー・インストール
COPY requirements.txt /code/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# プロジェクトをコピー
COPY . /code/

