#### Logger
#
#

define 'log', ["logWriter"], () ->


  return {
    log: _log
    info: _info
    warn: warn
    error: error    
  }