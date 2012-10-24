# Vision:  A generic interface to basic queue functionality in R.
#
# Currently supports activeMQ and rabbitMQ.
# 
# Author: msm336
###############################################################################


.onLoad <-
	function(libname, pkgname) {
		.jpackage(pkgname, lib.loc = libname)
	}


# Make a connection to a queue, and generate a consumer for it.
#
# Returns the consumer instance, null if the connection couldn't be established
#
# url: url to the host machine
# queue: name of the queue
# queueType: activeMQ, rabbitMQ
messageQueue.factory.getConsumerFor <-
	function(url, queue, queueType) {
		# call the MessageQueueFactory.getConsumerFor static method
		consumer <- .jcall(J("edu/cornell/clo/r/message_queue/MessageQueueFactory"), "Ledu/cornell/clo/r/message_queue/Consumer","getConsumerFor", url, queue, queueType)
		return(consumer);
	}

# Make a connection to a queue, and generate a producer for it.
#
# Returns: the producer instance, null if the connection couldn't be established
#
# url: url to the host machine
# queue: name of the queue
# queueType: activeMQ, rabbitMQ
messageQueue.factory.getProducerFor <-
	function(url, queue, queueType) {
		# call the MessageQueueFactory.getConsumerFor static method
		consumer <- .jcall(J("edu/cornell/clo/r/message_queue/MessageQueueFactory"), "Ledu/cornell/clo/r/message_queue/Producer","getProducerFor", url, queue, queueType)
		return(consumer);
	}


# Check for a message on the queue.
# Non-blocking
messageQueue.consumer.getNextText <-
	function(consumer) {
		message <- .jcall(consumer, "S", "getNextText")
		return(message);
	}


# Close the consumer, deallocate resources.
# Non-blocking
messageQueue.consumer.close <-
	function(consumer) {
		status <- .jcall(consumer, "I", "close")
		return(status);
	}

	
# Add the following text to the noted queue
# Non-blocking
messageQueue.producer.putText <-
	function(producer, text) {
		status <- .jcall(producer, "I", "putText", text)
		return(status);
	}
	

# Close the producer, deallocate resources.
# Non-blocking
messageQueue.producer.close <-
	function(producer) {
		status <- .jcall(producer, "I", "close")
		return(status);
	}
	
	

# steps for building/packaging
# 1.  copy JAR to project directory/inst/java/messageQueue.jar, where .onLoad will load it
# 2.  packaging code
#     R> package.skeleton(name="messageQueue", code_files=c("messageQueue.R"), list=c("messageQueue.factory.getProducerFor", "messageQueue.producer.close", "messageQueue.producer.putText", "messageQueue.factory.getConsumerFor", "messageQueue.consumer.close", "messageQueue.consumer.getNextText"))
# 3.  tar it up
#     R> build
# 4.  check the build
#     R> check
# 