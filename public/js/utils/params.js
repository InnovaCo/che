(function() {

  define(function() {
    var params;
    params = function(data, prefix, result) {
      var field, nextPrefix, nextValue, value;
      result = result || [];
      if (_.isString(data)) {
        result.push((prefix || "") + ("=" + (encodeURIComponent(data))));
      } else {
        for (field in data) {
          value = data[field];
          if (prefix != null) {
            nextPrefix = prefix + ("[" + field + "]");
          } else {
            nextPrefix = field;
          }
          if (_.isFunction(value)) {
            nextValue = value();
          } else {
            nextValue = value;
          }
          params(nextValue, nextPrefix, result);
        }
      }
      return encodeURI(result.join("&"));
    };
    return function(data) {
      if (_.isFunction(data)) {
        return params(data());
      } else if (_.isObject(data)) {
        return params(data);
      } else {
        return data != null ? data.toString() : void 0;
      }
    };
  });

}).call(this);
