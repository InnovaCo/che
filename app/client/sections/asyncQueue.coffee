define ["lib/async"], (async) ->
  asyncQueue = async()
  asyncQueue.name = "sectionsAsyncQueue"

  return asyncQueue;