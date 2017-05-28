function handleRecipeTyping(e) {
  if (e.keyCode == 13) {
    // get text in the input now
    var text = $('input.recipe-search-input').val();
    navigateTo("/recipes?q=" + text);
    //console.log(text);
    //updatePage([".recipe-tiles"], {params: {q: text}});
  }
}

/* HELPER METHODS */

function isSignedIn() {
  return window.currentUser != null;
}

function setCurrentUser(user) {
  window.currentUser = user;
}

var openModals = {};

function showModalFromURL(id, url, opts={}) {
  if (opts.overlap == false) {
    closeModals();
  }
  var m = $.dialog({
    title: null,
    content: "URL:" + url,
    closeIcon: (opts.closeIcon != false),
  });
  openModals[id] = m;
  return m;
}

function closeModal(id) {
  var m = openModals[id];
  if (m) {
    m.close();
  }
}

function updateFlagAndCloseModal(flag, id) {
  apiRequest({
    url: "/account/update_flags",
    data: {flags: JSON.stringify([flag])},
    success: function(resp) {
      closeModal(id);
    }
  });
}

function closeModals() {
  for (var m in openModals) {
    openModals[m].close();
  }
  openModals = {};
}

function apiRequest(opts) {
  opts.dataType = opts.dataType || 'json';
  opts.method = opts.method || 'POST';
  opts.hasFile = opts.hasFile || false;

  var data = opts.data;

  if (opts.hasFile == true) {
    data = new FormData();
    for (var prop in opts.data) {
      data.append(prop, opts.data[prop]);
    }
  }

  var aopts = {
    url: opts.url,
    dataType: opts.dataType,
    method: opts.method,
    success: opts.success,
    data: data,
    error: function(xhr) {
      try {
        resp = JSON.parse(xhr.responseText);
      } catch (e) {
        resp = {success: false, error: "An error occurred."};
      }
      if (opts.error) {
        opts.error(resp);
      }
    }
  };

  if (opts.hasFile == true) {
    aopts.processData = false;
    aopts.contentType = false;
  }

  $.ajax(aopts);
}

function updatePage(element_classes, opts={}) {
  var url = location.pathname;
  var data = opts.params || {};
  apiRequest({
    data: data,
    url: url,
    method: 'GET',
    dataType: 'html',
    success: function (resp) {
      $new_html = $(resp);
      for (var element_class of element_classes) {
        //console.log(element_class);
        var changed = $new_html.find(element_class).addBack(element_class).html();
        //console.log(changed);
        $(element_class).html(changed);
      }
    }
  });
}


function navigateTo(url) {
  window.location.href = url;
}

function getURLParams() {
  var url = window.location.href;
  var query = url.split("?")[1];
  ret = {};
  if (query) {
    //console.log(query);
    var qps = query.split("&");
    //console.log(qps);
    for (const qp of qps) {
      //console.log(qp);
      qpfs = qp.split("=");
      ret[qpfs[0]] = unescape(qpfs[1]);
    }
  }
  return ret;
}
