DOCKER_NETWORK = docker-hadoop_default
ENV_FILE = hadoop.env
current_branch := $(shell git rev-parse --abbrev-ref HEAD)
base_version := --build-arg HADOOP_BASE_VERSION=$(current_branch)
build:
	docker build -t bde2020/hadoop-base:$(current_branch) ./base
	docker build -t bde2020/hadoop-namenode:$(current_branch) $(base_version) ./namenode
	docker build -t bde2020/hadoop-datanode:$(current_branch) $(base_version) ./datanode
	docker build -t bde2020/hadoop-resourcemanager:$(current_branch) $(base_version) ./resourcemanager
	docker build -t bde2020/hadoop-nodemanager:$(current_branch) $(base_version) ./nodemanager
	docker build -t bde2020/hadoop-historyserver:$(current_branch) $(base_version) ./historyserver
	docker build -t bde2020/hadoop-submit:$(current_branch) $(base_version) ./submit

up:
	CURRENT_BRANCH=$(current_branch) docker-compose up

fs:
	docker exec -it namenode sh
	##hdfs dfs -head /input/README.txt

wordcount:
	docker build -t hadoop-wordcount ./submit
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} bde2020/hadoop-base:$(current_branch) hdfs dfs -mkdir -p /input/
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} bde2020/hadoop-base:$(current_branch) hdfs dfs -copyFromLocal -f /opt/hadoop/README.txt /input/
	docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	#docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} bde2020/hadoop-base:$(current_branch) hdfs dfs -cat /output/*
	#docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} bde2020/hadoop-base:$(current_branch) hdfs dfs -rm -r /output
	#docker run --rm --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} bde2020/hadoop-base:$(current_branch) hdfs dfs -rm -r /input
