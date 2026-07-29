# 13.6
FROM debian@sha256:fac46bff2e02f51425b6e33b0e1169f55dfb053d83511ca28aa50c09fd5ed7a4

# Required due to git feature installing from source, while terraform feature requires github feature which requires git installing from package manager
RUN apt-get update && apt-get install -y git
