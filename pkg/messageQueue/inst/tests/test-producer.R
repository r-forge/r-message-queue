
# https://github.com/hadley/devtools/wiki/Testing

# this allows tests to run without actually running an ActiveMQ server
# but it causes an exception if we don't cleanup the RCheck directory
#host <- "vm:localhost?broker.persistent=false";
host <- "tcp://ag-clo-ampbuild:61616";

context("producer");

test_that("producer connects to a queue", {
	producer.queue = messageQueue.factory.getProducerFor(host, "r-outbound-queue", "activeMQ");
	expect_false(is.null(producer.queue));
	
	messageQueue.producer.close(producer.queue);
})

test_that("producer can close a queue", {
	producer.queue = messageQueue.factory.getProducerFor(host, "r-outbound-queue", "activeMQ");
	expect_false(is.null(producer.queue));
	
	status <- messageQueue.producer.close(producer.queue);
	expect_equal(status, 1);
})
			

# queue should be empty
test_that("producer can produce a message", {
	producer.queue = messageQueue.factory.getProducerFor(host, "r-outbound-queue", "activeMQ");

	status <- messageQueue.producer.putText(producer.queue, "this is the message");
	expect_equal(status, 1);
#	expect_true(status > 0, label="status isn't greater than 0", info=paste("status = ",status, sep=""));
})


# queue should be empty
test_that("producer can produce a message, consumer can consume it", {
	producer.queue = messageQueue.factory.getProducerFor(host, "r-outbound-queue", "activeMQ");
	consumer.queue = messageQueue.factory.getConsumerFor(host, "r-outbound-queue", "activeMQ");

	status <- messageQueue.producer.putText(producer.queue, "test-message-1", "corr-id", "replyTo");
	expect_equal(status, 1);
	
	consumer.message <- messageQueue.consumer.getNextText(consumer.queue);
	expect_true(!is.null(consumer.message),label="Message is null");
	
	# decode from a java string object
	correlationId <- .jstrVal(consumer.message$correlationId);
	expect_true(!is.null(correlationId));
	expect_equal(correlationId,"corr-id");

	# decode from a java string object
	replyTo <- .jstrVal(consumer.message$replyTo);
	expect_true(!is.null(replyTo));
	expect_equal(replyTo, "replyTo");
	
	request <- .jstrVal(consumer.message$value);
	expect_true(!is.null(request));
	expect_equal(request, "test-message-1", info=paste("actual value: '", request,"'", sep=""));
	
	
#	expect_true(status > 0, label="status isn't greater than 0", info=paste("status = ",status, sep=""));
})


# add message to a queue

# retrieve message from a queue

# inspect properties of a message

# send message to a replyTo queue