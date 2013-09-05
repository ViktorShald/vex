$ = jQuery

# Detect CSS Animation Support

animationEndSupport = false

$ ->
    s = (document.body || document.documentElement).style
    animationEndSupport = s.animation isnt undefined or s.WebkitAnimation isnt undefined or s.MozAnimation isnt undefined or s.MsAnimation isnt undefined or s.OAnimation isnt undefined

# Vex

vex =

    globalID: 1

    animationEndEvent: 'animationend webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend' # Inconsistent casings are intentional http://stackoverflow.com/a/12958895/131898

    baseClassNames:
        content: 'vex-content'
        overlay: 'vex-overlay'
        close: 'vex-close'
        closing: 'vex-closing'

    defaultOptions:
        content: ''
        showCloseButton: true
        overlayClosesOnClick: true
        appendLocation: 'body'
        className: ''
        css: {}
        overlayClassName: ''
        overlayCSS: {}
        closeClassName: ''
        closeCSS: {}

    open: (options) ->
        options = $.extend {}, vex.defaultOptions, options

        options.id = vex.globalID
        vex.globalID += 1

        # Overlay

        options.$vexOverlay = $('<div>')
            .addClass(vex.baseClassNames.overlay)
            .addClass(options.overlayClassName)
            .css(options.overlayCSS)
            .data(vex: options)

        if options.overlayClosesOnClick
            options.$vexOverlay.bind 'click.vex', (e) ->
                return unless e.target is @
                vex.close $(@).data().vex.id

        # Content

        options.$vexContent = $('<div>')
            .addClass(vex.baseClassNames.content)
            .addClass(options.className)
            .css(options.css)
            .append(options.content)
            .data(vex: options)

        options.$vexOverlay.append options.$vexContent

        # Close button

        if options.showCloseButton
            options.$closeButton = $('<div>')
                .addClass(vex.baseClassNames.close)
                .addClass(options.closeClassName)
                .css(options.closeCSS)
                .data(vex: options)
                .bind('click.vex', -> vex.close $(@).data().vex.id)

            options.$vexContent.append options.$closeButton

        # Inject DOM and trigger callbacks/events

        $(options.appendLocation).append options.$vexOverlay

        # Call afterOpen callback and trigger vexOpen event

        options.afterOpen options.$vexContent, options if options.afterOpen
        setTimeout (-> options.$vexContent.trigger 'vexOpen', options), 0

        return options.$vexContent # For chaining

    getAllVexes: ->
        return $(""".#{vex.baseClassNames.overlay}:not(".#{vex.baseClassNames.closing}") .#{vex.baseClassNames.content}""")

    getVexByID: (id) ->
        return vex.getAllVexes().filter(-> $(@).data().vex.id is id)

    close: (id) ->
        if not id
            $lastVexContent = vex.getAllVexes().last()
            return false unless $lastVexContent.length
            id = $lastVexContent.data().vex.id

        return vex.closeByID id

    closeAll: ->
        ids = vex.getAllVexes().map(-> $(@).data().vex.id)
        return false unless ids and ids.length

        $.each ids.reverse(), (index, id) -> vex.closeByID id

        return true

    closeByID: (id) ->
        $vexContent = vex.getVexByID id
        return unless $vexContent.length

        $vexOverlay = $vexContent.data().vex.$vexOverlay

        options = $.extend {}, $vexContent.data().vex

        beforeClose = ->
            options.beforeClose $vexContent, options if options.beforeClose

        close = ->
            $vexContent.trigger 'vexClose', options
            $vexOverlay.remove()
            options.afterClose $vexContent, options if options.afterClose

        if animationEndSupport
            beforeClose()
            $vexOverlay
                .unbind(vex.animationEndEvent).bind(vex.animationEndEvent, -> close())
                .addClass(vex.baseClassNames.closing)

        else
            beforeClose()
            close()

        return true

    hideLoading:  ->
        $('.vex-loading-spinner').remove()

    showLoading: ->
        vex.hideLoading()
        $('body').append('<div class="vex-loading-spinner"></div>')

window.vex = vex