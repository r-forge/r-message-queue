# Vision:  A generic interface to basic queue functionality in R.
#
# Currently supports activeMQ and rabbitMQ.
# 
# Author: matthew.macgillivray@cornell.edu
#
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
		
		if (queueType == "activeMQ" || queueType == "activemq" || queueType == "rabbitmq" || queueType == "rabbitMQ") { 
			# static call
			consumer <- .jcall(J("edu/cornell/clo/r/message_queue/MessageQueueFactory"), "Ledu/cornell/clo/r/message_queue/Consumer;","getConsumerFor", url, queue, queueType)
			
			if (is.null(consumer)) {
				cat("WARNING: consumer is null.  Not sure why.\n");
			}
		} else {
			cat("ERROR: queueType must be one of (activeMQ, rabbitMQ), not: " + queueType + "\n");
		}
	
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
	
		if (tolower(queueType) == "activemq" || tolower(queueType) == "rabbitmq") { 
			# static call
			producer <- .jcall(J("edu/cornell/clo/r/message_queue/MessageQueueFactory"), "Ledu/cornell/clo/r/message_queue/Producer;","getProducerFor", url, queue, queueType)
		
			if (is.null(producer)) {
				cat("WARNING: producer is null.  Not sure why.\n");
			}
		} else {
			cat("ERROR: queueType must be one of (activeMQ, rabbitMQ), not: " + queueType + "\n");
		}
	
		return(producer);
	}


# Check for a message on the queue.
# Non-blocking
messageQueue.consumer.getNextText <-
	function(consumer) {
		smessage = NULL;
		if (!is.null(consumer)) {
#			message <- .jcall(consumer, "Ljava/lang/String;", "getNextText");
			cat(" before 'getNextText'\n");
			message <- .jcall(consumer, "Ledu/cornell/clo/r/message_queue/STextMessage;", "getNextText");
			
			# decode from java.lang.String objects to R strings
			if (!is.null(message)) {
				cat("message retrieved\n");
				smessage <- list("value" = .jstrVal(message$value), "correlationId" = .jstrVal(message$correlationId), "replyTo" = .jstrVal(message$replyTo));
				#smessage = NULL;
				cat(paste("retrieved message$value: '", smessage$value,"', message$correlationId: '",smessage$correlationId,"', message$replyTo: '",smessage$replyTo,"'\n", sep=""));
				
#				if (!is.null(message$value)) {
#					smessage$value <- .jstrVal(message$value);
#				}
#				if (!is.null(message$correlationId)) {
#					smessage$correlationId <- .jstrVal(message$correlationId);
#				}
#				if (!is.null(message$replyTo)) {
#					smessage$replyTo <- .jstrVal(message$replyTo);
#				}
				
			} else {
				cat(paste("no message retrieved status: ", consumer$lastStatusCode, "\n", sep=""));
				smessage = NULL;
				return(NULL);
			}
		
			# this fancy, nice syntax doesn't seem to work
			if (consumer$lastStatusCode < 0) {
				cat(consumer$getStatusString(consumer$lastStatusCode));
			}
		} else {
			cat("ERROR: consumer is null.\n");
			smessage = NULL;
			return(NULL);
		}
		return(smessage);
	}


	
	
# EXCLUSIVELY used for testing
messageQueue.consumer.clearQueue <-
	function(consumer) {
		if (!is.null(consumer)) {
			cat(" clearing queue...\n");
		
			i <- 0;
			# loop until the queue is empty
			repeat {
				message <- .jcall(consumer, "Ledu/cornell/clo/r/message_queue/STextMessage;", "getNextText");
			
				# 3 null messages? break..
				if (is.null(message)) {
					i <- i+1;
					if (i > 2) {
						break;
					}
				}
			}
			cat(" clearing queue... done\n");
		}
	}
	
	
	

# Close the consumer, deallocate resources.
# Non-blocking
messageQueue.consumer.close <-
	function(consumer) {
		if (!is.null(consumer)) {
			status <- .jcall(consumer, "I", "close")
		
			# this fancy, nice syntax doesn't seem to work
			if (status < 0) {
				cat(consumer$getStatusString(status));
			}
		} else {
			cat("ERROR: consumer is null.\n");
			status = -5;
		}
		return(status);
	}

	
	
# Add the following text to the noted queue
# Non-blocking
# 
# result codes:
# -5: producer is null
# -4: session is null, can't create a message (in java)
# -2: JMS exception trying to send the message (in java)
# -1: unknown error
#  1: success
messageQueue.producer.putText <-
	function(producer, text, correlationId = "", replyToQueue = "") {
		if (!is.null(producer) && !is.null(text)) {
			status <- .jcall(producer, "I", "putText", text, correlationId, replyToQueue)
			
			if (status < 0) {
				cat(producer$getStatusString(status));
			}
		} else {
			cat("ERROR: producer is null, or text is null.\n");
			status = -5;
		}
		return(status);
	}
	
	
	

# Close the producer, deallocate resources.
# Non-blocking
messageQueue.producer.close <-
	function(producer) {
		if (!is.null(producer)) {
			status <- .jcall(producer, "I", "close")
			
			if (status < 0) {
				cat(producer$getStatusString(status));
			}
		} else {
			cat("ERROR: producer is null.\n");
			status = -5;
		}
		return(status);
	}
	
	

# steps for building/packaging
# 1.  copy JAR to project directory/inst/java/messageQueue.jar, where .onLoad will load it
# 2.  packaging code
#     R> package.skeleton(name="messageQueue", code_files=c("messageQueue.R"), list=c("messageQueue.factory.getProducerFor", "messageQueue.producer.close", "messageQueue.producer.putText", "messageQueue.factory.getConsumerFor", "messageQueue.consumer.close", "messageQueue.consumer.getNextText"))
# 3.  tar it up
#     R> build
# 4.  check the build just for the arch we are running on, which will also run the test cases
#     R> check --no-multiarch
# 
