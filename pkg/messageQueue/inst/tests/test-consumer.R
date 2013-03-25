
# https://github.com/hadley/devtools/wiki/Testing

# this allows tests to run without actually running an ActiveMQ server
#host <- "vm:localhost?broker.persistent=false";
host <- "tcp://ag-clo-ampbuild:61616";

context("consumer");

test_that("consumer connects to a queue", {
	consumer.queue = messageQueue.factory.getConsumerFor(host, "r-inbound-queue", "activeMQ");
	expect_false(is.null(consumer.queue));
	
	messageQueue.consumer.close(consumer.queue);
})

test_that("consumer can close a queue", {
	consumer.queue = messageQueue.factory.getConsumerFor(host, "r-inbound-queue", "activeMQ");
	expect_false(is.null(consumer.queue));
	expect_true(messageQueue.consumer.close(consumer.queue) > 0);
})
			

# queue should be empty
test_that("consumer retrieves no messages", {
	consumer.queue = messageQueue.factory.getConsumerFor(host, "r-inbound-queue", "activeMQ");
	
#	consumer.message <- messageQueue.consumer.getNextText(consumer.queue);
#	expect_false(is.null(consumer.message));
})




# add message to a queue

# retrieve message from a queue

# inspect properties of a message

# send message to a replyTo queue