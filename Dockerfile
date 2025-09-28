# 使用 Ruby 官方镜像作为基础镜像
FROM ruby:3.3.4

# 创建一个新的目录用于存放 Jekyll 网站
RUN mkdir /blog
WORKDIR /blog
 
# 安装依赖
COPY Gemfile /blog
RUN bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems
RUN bundle install --verbose

# 容器启动时执行的命令
CMD jekyll --version
