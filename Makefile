PROTO_PATH = proto
POM_FILE = target/classes/META-INF/maven/com.example.grpc/grpc-example/pom.xml

.PHONY: all clean proto jar deploy

all: deploy

clean:
	rm -rf target pom.xml java/src clojure/src

version:
	clj -T:build print-version

proto: clean
	mkdir -p clojure/src
	mkdir -p java/src
	protoc --java_out=java/src --proto_path=$(PROTO_PATH) $(PROTO_PATH)/*.proto
	protoc --plugin=protoc-gen-grpc-java=bin/protoc-gen-grpc-java-1.37.0-linux-x86_64.exe --grpc-java_out=java/src --proto_path=$(PROTO_PATH) $(PROTO_PATH)/*.proto
	protoc --plugin=bin/protoc-gen-clojure-0.9.5-SNAPSHOT.exe --clojure_out=grpc-client,grpc-server:clojure/src --proto_path=$(PROTO_PATH) $(PROTO_PATH)/*.proto

jar: proto
	clj -T:build jar
	cp $(POM_FILE) .

deploy: jar
	mvn deploy:deploy-file -Dfile=`ls target/*.jar` -DrepositoryId=PRIVATE_REPO_ID -Durl=PRIVATE_REPO_URL -DpomFile=pom.xml
