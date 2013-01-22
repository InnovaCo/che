(function() {

  define(function() {
    var params;
    params = function(data, prefix, result) {
      var encodedField, field, nextPrefix, nextValue, value;
      result = result || [];
      if (_.isString(data)) {
        result.push((prefix || "") + ("=" + (encodeURIComponent(data))));
      } else {
        for (field in data) {
          value = data[field];
          encodedField = encodeURIComponent(field);
          nextPrefix = prefix != null ? prefix + ("[" + encodedField + "]") : encodedField;
          nextValue = (typeof value === "function" ? value() : void 0) || value;
          params(nextValue, nextPrefix, result);
        }
      }
      return result;
    };
    return function(data) {
      if (_.isFunction(data)) {
        return encodeURI((params(data())).join("&"));
      }
      if (_.isObject(data)) {
        return encodeURI((params(data)).join("&"));
      }
      return data != null ? data.toString() : void 0;
    };
  });

}).call(this);
