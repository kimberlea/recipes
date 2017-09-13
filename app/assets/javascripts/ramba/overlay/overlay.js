(function() {
  this.Overlay = (function() {
    function Overlay() {
      this.zindex = 100;
      this.notifyTimer = null;
    }

    return Overlay;

  })();

  Overlay.instance = new Overlay();

  Overlay.templates = {
    loading_overlay: function(opts) {
      return "<div class='overlay-spinner-1'></div>";
    },
    notify: function(opts) {
      return "<div class='message'>" + opts.message + "</div>";
    },
    modal_close_button_content: "&times;"
  };

  Overlay.remove = function(id) {
    Overlay.removeModal(id);
    return Overlay.removePopover(id);
  };

  Overlay.isVisible = function(id) {
    return $('#overlay-' + id).length > 0;
  };

  Overlay.show_loading = function() {
    var $overlay, tpl;
    $overlay = $("#overlay-loading-screen");
    $overlay.remove();
    tpl = "<div id='overlay-loading-screen' class='overlay-loading-screen'><div class='progress progress-striped active'><div class='progress-bar' style='width: 100%'></div></div></div>";
    $overlay = $(tpl);
    return $overlay.appendTo("body").fadeIn();
  };

  Overlay.hide_loading = function() {
    var $overlay;
    $overlay = $("#overlay-loading-screen");
    return $overlay.fadeOut({
      complete: function() {
        return $overlay.remove();
      }
    });
  };

  Overlay.utils = {
    getElementPosition: function(el) {
      var rect, ret;
      if (el.getBoundingClientRect != null) {
        rect = el.getBoundingClientRect();
        ret = {
          width: rect.width,
          height: rect.height,
          top: rect.top,
          left: rect.left,
          bottom: rect.bottom,
          right: rect.right
        };
      } else {
        ret = $(el).offset();
        ret.width = el.offsetWidth;
        ret.height = el.offsetHeight;
        ret.right = ret.left + ret.width;
        ret.bottom = ret.top + ret.height;
      }
      return ret;
    },
    lastGlobalZIndex: 2000,
    availableZIndex: function(el) {
      var ret, vals;
      if (el == null) {
        ret = Overlay.utils.lastGlobalZIndex;
        Overlay.utils.lastGlobalZIndex += 10;
        return ret;
      } else {
        vals = $(el).parents().map(function() {
          var val;
          val = parseInt($(this).css('z-index'));
          if (isNaN(val)) {
            return 0;
          } else {
            return val;
          }
        });
        return Math.max.apply(null, vals) + 10;
      }
    },
    isModalOpen: function() {
      return $('.modal.in').length > 0;
    },
    positionPopover: function($po) {
      var $arrow, $container, an_h, an_l, an_t, an_w, anchor, anchor_pos, i, left, len, opts, pl, placement, po_h, po_w, ref, screen_height, top, win_rect;
      if ($po.length === 0) {
        return;
      }
      $arrow = $po.find('.arrow');
      opts = $po.data('overlay.popover');
      anchor = opts.anchor;
      $container = opts.$container;
      anchor_pos = Overlay.utils.getElementPosition(anchor);
      an_t = anchor_pos.top;
      an_l = anchor_pos.left;
      an_w = anchor_pos.width;
      an_h = anchor_pos.height;
      po_w = $po[0].offsetWidth;
      po_h = $po[0].offsetHeight;
      win_rect = Overlay.utils.getElementPosition(opts.$container[0]);
      screen_height = $(window).height();
      if (opts.container === 'body' && screen_height > win_rect.height) {
        win_rect.height = screen_height;
        win_rect.bottom = screen_height;
      }
      top = 0;
      left = 0;
      placement = null;
      ref = opts.placement.split(' ');
      for (i = 0, len = ref.length; i < len; i++) {
        pl = ref[i];
        placement = pl;
        switch (pl) {
          case 'bottom':
            top = an_t + an_h;
            left = an_l + an_w / 2 - po_w / 2;
            break;
          case 'top':
            top = an_t - po_h;
            left = an_l + an_w / 2 - po_w / 2;
            break;
          case 'left':
            left = an_l - po_w;
            if (opts.top != null) {
              top = an_t + opts.top;
            } else {
              top = an_t + an_h / 2 - po_h / 2;
            }
            break;
          case 'right':
            left = an_l + an_w;
            if (opts.top != null) {
              top = an_t + opts.top;
            } else {
              top = an_t + an_h / 2 - po_h / 2;
            }
        }
        if ((left + po_w) > win_rect.right) {
          continue;
        }
        if (left < 0) {
          continue;
        }
        if (top < win_rect.top) {
          continue;
        }
        if ((top + po_h) > win_rect.bottom) {
          continue;
        } else {
          break;
        }
      }
      return $po.offset({
        top: top,
        left: left
      }).addClass(placement).addClass('in');
    }
  };

}).call(this);

(function() {
  Overlay.modal = function(opts) {
    var $modal_dialog, $modal_el, add_close, close_btn_html, cls, css_opts, id, modal_tpl, template, tmp, vm;
    vm = opts.view;
    tmp = opts.template;
    css_opts = opts.style || {};
    cls = opts.className || '';
    id = vm.name;
    template = tmp;
    add_close = opts.showCloseButton !== false;
    close_btn_html = opts.close_button_content || opts.closeButtonContent || Overlay.templates.modal_close_button_content || Overlay.templates.modalCloseButtonContent;
    $('#overlay-' + id).remove();
    if (opts.containerTemplate != null) {
      modal_tpl = opts.containerTemplate;
    } else {
      modal_tpl = "<div class='modal fade'><div class='modal-dialog'><div class='modal-content'>";
      if (add_close) {
        modal_tpl += "<button class='modal-default-close close' data-bind='click : hideOverlay'>" + close_btn_html + "</button>";
      }
      modal_tpl += "<div class='" + template + "' data-bind=\"updateContext : {'$view': $data}, template: '" + template + "'\"></div></div></div></div>";
    }
    $modal_el = $(modal_tpl).appendTo('body');
    $modal_dialog = $modal_el.find('.modal-dialog');
    if (opts.width != null) {
      $modal_dialog.css({
        width: opts.width + 'px'
      });
    }
    $modal_dialog.css(css_opts);
    $modal_el.addClass(cls);
    $modal_el.attr('id', "overlay-" + id);
    if (typeof opts.beforeBind === "function") {
      opts.beforeBind($modal_el);
    }
    setTimeout(function() {
      var context, root_context;
      root_context = ko.contextFor($('body')[0]);
      context = root_context.createChildContext(vm, '$view');
      $modal_el.koBind(context);
      $modal_el.on('hidden.bs.modal', function(ev) {
        if (ev.target.id !== ("overlay-" + id)) {
          return;
        }
        console.log('Hiding overlay.');
        setTimeout(function() {
          $modal_el.koClean();
          return $modal_el.remove();
        }, 100);
        vm.hide();
        return vm.overlay_modal_element = null;
      });
      $modal_el.on('shown.bs.modal', function(ev) {
        if (ev.target.id !== ("overlay-" + id)) {
          return;
        }
        vm.show();
        vm.overlay_modal_element = $modal_el[0];
        if (opts.shown != null) {
          return opts.shown;
        }
      });
      $modal_el.on('hide.overlay.modal', function(ev) {
        return $modal_el.modal('hide');
      });
      return $modal_el.modal(opts);
    }, 100);
    return $modal_el[0];
  };

  Overlay.removeModal = function(id) {
    return $('#overlay-' + id).trigger('hide.overlay.modal');
  };

  Overlay.dialog = function(msg, opts) {
    var vm;
    vm = {
      name: 'dialog',
      message: ko.observable(msg),
      yes: opts.yes,
      no: opts.no,
      cancel: Overlay.remove('dialog')
    };
    return Overlay.modal({
      view: vm,
      template: 'view-dialog',
      width: 300
    });
  };

  Overlay.closeDialog = function() {
    return this.remove('dialog');
  };

  Overlay.confirm = function(msg, opts) {
    var $modal, tmp, vm;
    opts.title || (opts.title = "Continue?");
    vm = {
      message: msg,
      title: opts.title,
      yes: function() {
        $('#overlay-confirm').modal('hide');
        if (opts.yes != null) {
          return opts.yes();
        }
      },
      no: function() {
        $('#overlay-confirm').modal('hide');
        if (opts.no != null) {
          return opts.no();
        }
      },
      yes_text: opts.yes_text || "Yes",
      no_text: opts.no_text || "No"
    };
    tmp = "<div id='overlay-confirm' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div> <div class='modal-body' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-default' data-bind='click : no, html : no_text'>No</button><button class='btn btn-success' data-bind='click : yes, html : yes_text'>Yes</button></div> </div> </div> </div>";
    $modal = $('#overlay-confirm');
    if ($modal.length === 0) {
      $modal = $(tmp);
      $modal.appendTo('body');
    } else {
      $modal.koClean();
      $modal.removeClass('animated shake');
    }
    $modal.koBind(vm);
    return $modal.modal({
      backdrop: 'static',
      attentionAnimation: 'shake'
    });
  };

  Overlay.alert = function(msg, opts) {
    var $modal, tmp, vm;
    opts || (opts = {});
    opts.title || (opts.title = "Alert!");
    vm = {
      message: msg,
      title: opts.title,
      ok: function() {
        $('#overlay-alert').modal('hide');
        if (opts.ok != null) {
          return opts.ok();
        }
      }
    };
    tmp = "<div id='overlay-alert' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div> <div class='modal-body' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-primary' data-bind='click : ok'>OK</button></div> </div> </div> </div>";
    $modal = $('#overlay-alert');
    if ($modal.length === 0) {
      $modal = $(tmp);
      $modal.appendTo('body');
    } else {
      $modal.koClean();
    }
    $modal.koBind(vm);
    return $modal.modal({
      backdrop: 'static',
      attentionAnimation: 'shake'
    });
  };

}).call(this);

(function() {
  Overlay.notify = function(msg, type, opts) {
    var $notif;
    opts = opts || {};
    opts.timeout = opts.timeout || 3000;
    opts.position = opts.position || 'right';
    opts.message = msg;
    opts.type = type = type || 'info';
    Overlay.clearNotifications();
    $('body').prepend("<div id='overlay-notify' class='overlay-notify " + type + " p-" + opts.position + "' style='display: none;'>" + (Overlay.templates.notify(opts)) + "</div>");
    $notif = $('#overlay-notify');
    if ((opts.css != null)) {
      $notif.addClass(opts.css);
    }
    return $notif.fadeIn('slow', function() {
      return Overlay.instance.notifyTimeout = setTimeout(function() {
        return $notif.fadeOut('slow');
      }, opts.timeout);
    });
  };

  Overlay.clearNotifications = function() {
    clearTimeout(Overlay.instance.notifyTimeout);
    return $('#overlay-notify').remove();
  };

  Overlay.toast = function(msg, opts) {
    var $parent, $toast, $win, padding, pos, position, pr, th, timeout, tw, wh, ww;
    if (opts == null) {
      opts = {};
    }
    position = opts.position || 'bottom right';
    padding = opts.padding || 20;
    timeout = opts.timeout || 3000;
    $toast = $("<div id='overlay-toast' class='overlay-toast animated' style='opacity: 0;'>" + msg + "</div>");
    if (opts.className != null) {
      $toast.addClass(opts.className);
    }
    if (opts.container != null) {
      $parent = $(opts.container);
      pr = Overlay.utils.getElementPosition(opts.container);
    } else {
      $parent = $('body');
      $win = $(window);
      ww = $(window).width();
      wh = $(window).height();
      pr = {
        top: 0,
        left: 0,
        width: ww,
        height: wh,
        right: ww,
        bottom: wh
      };
    }
    $toast.appendTo('body');
    tw = $toast.outerWidth();
    th = $toast.outerHeight();
    pos = {};
    if (position === 'center') {
      pos.left = pr.width / 2 - tw / 2;
      pos.top = pr.height / 2 - th / 2;
    } else {
      if (position.includes('left')) {
        pos.left = pr.left + padding;
      } else {
        pos.right = pr.right + padding;
      }
      if (position.includes('top')) {
        pos.top = pr.top + padding;
      } else {
        pos.bottom = pr.bottom + padding;
      }
    }
    pos['z-index'] = Overlay.utils.availableZIndex($parent[0]);
    $toast.css(pos);
    $toast.addClass('fadeInUp');
    return setTimeout(function() {
      $toast.addClass('fadeOutDown');
      return setTimeout((function() {
        return $toast.remove();
      }), 1000);
    }, timeout);
  };

}).call(this);

(function() {
  Overlay.popover = function(el, opts) {
    var $backdrop, $po, container, id, tmp, vm;
    vm = opts.view;
    tmp = opts.template;
    id = vm.name;
    opts.placement || (opts.placement = 'right');
    opts.title || (opts.title = 'Options');
    opts.width || (opts.width = 'auto');
    opts.height || (opts.height = 'auto');
    opts.container || (opts.container = 'body');
    opts.top || (opts.top = null);
    opts.left || (opts.left = null);
    opts.anchor = el;
    if (opts.containerTemplate != null) {
      $po = $(opts.containerTemplate);
    } else {
      $po = $("<div class='popover fade'> <div class='arrow'></div> <div class='popover-inner'> <button class='close' data-bind='click : hidePopover'>&times;</button> <div class='" + tmp + "' data-bind=\"updateContext : {'$view': $data}, template : '" + tmp + "'\"></div> </div> </div>");
    }
    $po.attr('id', "popover-" + id);
    $backdrop = $("<div class='popover-backdrop'></div>");
    container = opts.container === 'parent' ? $(el).parent() : $(opts.container);
    opts.$container = container;
    setTimeout(function() {
      var zidx;
      zidx = Overlay.utils.availableZIndex();
      $po.remove().css({
        top: 0,
        left: 0,
        display: 'block',
        width: opts.width,
        height: opts.height,
        'z-index': zidx
      }).prependTo(container);
      if (opts.backdrop) {
        $backdrop.css({
          'z-index': zidx - 1
        });
        $backdrop.click(function() {
          return $po.trigger('hide.overlay.popover');
        });
        $backdrop.prependTo(document.body);
        opts.$backdrop = $backdrop;
      }
      if (opts.style != null) {
        $po.css(opts.style);
      }
      if (opts.className != null) {
        $po.addClass(opts.className);
      }
      if (opts.binding != null) {
        $po.attr('data-bind', opts.binding);
      }
      $po.koBind(vm);
      vm.overlay_popover_element = $po[0];
      vm.overlay_anchor_element = el;
      vm.show();
      $po.click(function(ev) {
        return ev.stopPropagation();
      });
      $po.on('hide.overlay.popover', function() {
        vm.hide();
        vm.overlay_popover_element = null;
        vm.overlay_anchor_element = null;
        $po.koClean().remove();
        return $backdrop.remove();
      });
      $po.on('reposition.overlay.popover', function() {
        return Overlay.utils.positionPopover($po);
      });
      $po.data('overlay.popover', opts);
      return Overlay.utils.positionPopover($po);
    }, 100);
    return $po[0];
  };

  Overlay.removePopover = function(id) {
    var $po;
    $po = $("#popover-" + id);
    return $po.trigger('hide.overlay.popover');
  };

  Overlay.removePopovers = function() {
    return $('.popover').each(function() {
      return $(this).trigger('hide.overlay.popover');
    });
  };

  Overlay.repositionPopover = function(id) {
    return Overlay.utils.positionPopover($("#popover-" + id));
  };

}).call(this);

(function() {
  var Modal;

  Modal = jQuery.fn.modal.Constructor;

  Modal.prototype.basic_show = Modal.prototype.show;

  Modal.prototype.show = function(_relatedTarget) {
    var anim, idx, self;
    self = this;
    this.basic_show(_relatedTarget);
    idx = $('.modal.in, .popover').length;
    idx = Overlay.utils.availableZIndex();
    if (this.$backdrop != null) {
      if (this.options.className != null) {
        this.$backdrop.addClass(this.options.className);
      }
      this.$backdrop.css('z-index', idx - 1);
    }
    this.$element.css('z-index', idx);
    if (this.options.attentionAnimation != null) {
      anim = this.options.attentionAnimation;
      return this.$element.on('click.dismiss.modal', function(ev) {
        if (ev.target !== ev.currentTarget) {
          return;
        }
        self.$element.removeClass("animated " + anim);
        return setTimeout(function() {
          return self.$element.addClass("animated " + anim);
        }, 10);
      });
    }
  };

  $(document).on('hidden.bs.modal', '.modal', function() {
    return setTimeout(function() {
      if (!Overlay.utils.isModalOpen()) {
        return $(document.body).removeClass('modal-open');
      } else {
        QS.log('adding modal class back');
        return $(document.body).addClass('modal-open');
      }
    }, 50);
  });

}).call(this);

(function() {
  QS.View.prototype.showAsModal = function(tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.modal(opts);
  };

  QS.View.prototype.showAsOverlay = QS.View.prototype.showAsModal;

  QS.View.prototype.showAsPopover = function(el, tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.popover(el, opts);
  };

  QS.View.prototype.repositionPopover = function(anchor) {
    var $el, opts;
    $el = $(this.overlay_popover_element);
    if (anchor != null) {
      opts = $el.data('overlay.popover');
      opts.anchor = anchor;
      this.overlay_anchor_element = anchor;
    }
    return $el.trigger('reposition.overlay.popover');
  };

  QS.View.prototype.hideOverlay = function() {
    this.hideModal();
    return this.hidePopover();
  };

  QS.View.prototype.hidePopover = function() {
    if (this.overlay_popover_element != null) {
      return $(this.overlay_popover_element).trigger('hide.overlay.popover');
    }
  };

  QS.View.prototype.hideModal = function() {
    if (this.overlay_modal_element != null) {
      return $(this.overlay_modal_element).trigger('hide.overlay.modal');
    }
  };

  QS.View.prototype.showToast = function(msg, opts) {
    if (opts == null) {
      opts = {};
    }
    opts.container || (opts.container = this.element);
    return Overlay.toast(msg, opts);
  };

  QS.View.displayModal = function(owner, opts) {
    var dvn, ov, ov_opts;
    if (opts == null) {
      opts = {};
    }
    dvn = this.name + "-" + (Date.now());
    ov = new this(dvn, owner, opts.model, opts);
    ov.load(opts);
    ov_opts = ov.modalOptions || ov.overlayOptions || {};
    ov.showAsModal(ov.templateID, ov_opts);
    return ov;
  };

  QS.View.displayPopover = function(el, owner, opts) {
    var dvn, ov, ov_opts;
    if (opts == null) {
      opts = {};
    }
    dvn = this.name + "-" + (Date.now());
    ov = new this(dvn, owner, opts.model, opts);
    ov.load(opts);
    ov_opts = $.extend({}, ov.popoverOptions || {}, opts.popoverOptions || {});
    return ov.showAsPopover(el, ov.templateID, ov_opts);
  };

  ko.bindingHandlers.popover = {
    init: function(element, valueAccessor, bindingsAccessor, viewModel) {
      var opts;
      opts = valueAccessor();
      opts.view || (opts.view = viewModel);
      return $(element).click(function() {
        return Overlay.popover(element, opts);
      });
    }
  };

  ko.bindingHandlers.tip = {
    init: function(element, valueAccessor, bindingsAccessor, viewModel, bindingContext) {
      var $el, buildTip, opts;
      opts = ko.unwrap(valueAccessor());
      $el = $(element);
      buildTip = function() {
        var $tip_el, content, tip;
        content = opts.template_id != null ? "<div data-bind=\"template : '" + opts.template_id + "'\"></div>" : opts.content;
        opts.placement || (opts.placement = 'bottom');
        opts.html = opts.html || (opts.template_id != null) || false;
        opts.title || (opts.title = content);
        opts.container || (opts.container = 'body');
        $el.tooltip(opts);
        tip = $el.data('bs.tooltip');
        $tip_el = tip.tip();
        if (opts.className != null) {
          $tip_el.addClass(opts.className);
        }
        tip.setContent();
        tip.setContent = function(content) {
          var etfn;
          if (content == null) {
            return;
          }
          tip.options.title = content;
          if (opts.template_id != null) {

          } else {
            etfn = (opts.html === true) ? 'html' : 'text';
            return $tip_el.find('.tooltip-inner')[etfn](content);
          }
        };
        $tip_el.koBind(viewModel);
        tip.show();
        return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
          $tip_el.koClean();
          return tip.destroy();
        });
      };
      $el.on('mouseover', function() {
        if ($el.data('bs.tooltip') == null) {
          return buildTip();
        }
      });
      return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
        return $el.off('mouseover');
      });
    },
    update: function(element, valueAccessor, bindingsAccessor, viewModel, bindingContext) {
      var opts, tip;
      opts = ko.unwrap(valueAccessor());
      tip = $(element).data('bs.tooltip');
      if (tip != null) {
        return tip.setContent(opts.content);
      }
    }
  };

  ko.bindingHandlers.loadingOverlay = {
    update: function(element, valueAccessor) {
      var $el, is_loading;
      $el = $(element);
      is_loading = ko.utils.unwrapObservable(valueAccessor());
      if (is_loading) {
        if ($el.children('.overlay-loading-inline').length === 0) {
          return $el.prepend("<div class='overlay-loading-inline'>" + (Overlay.templates.loading_overlay()) + "</div>");
        } else {
          return $el.children('.overlay-loading-inline').stop().show();
        }
      } else {
        return $(element).children('.overlay-loading-inline').fadeOut('fast');
      }
    }
  };

}).call(this);
