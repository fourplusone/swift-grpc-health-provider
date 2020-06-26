SOURCE_DIR = Sources/HealthProvider

GRPC_SWIFT_OPT=Visibility=Public
PROTOBUF_SWIFT_OPT=Visibility=Public

all: grpc protobuf

protobuf: $(SOURCE_DIR)/*.pb.swift

grpc: $(SOURCE_DIR)/*.grpc.swift 

clean:
	rm -f $(SOURCE_DIR)/*.pb.swift $(SOURCE_DIR)/*.grpc.swift
	
.PHONY: clean

$(SOURCE_DIR)/%.pb.swift: $(SOURCE_DIR)/%.proto
	protoc --swift_out=$(PROTOBUF_SWIFT_OPT):. $<
	
$(SOURCE_DIR)/%.grpc.swift: $(SOURCE_DIR)/%.proto
	protoc --grpc-swift_out=$(GRPC_SWIFT_OPT):. $<
	
