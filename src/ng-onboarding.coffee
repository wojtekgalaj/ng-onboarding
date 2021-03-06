#
# ngOnboarding
# by Adam Albrecht
# http://adamalbrecht.com
#
# Source Code: https://github.com/adamalbrecht/ngOnboarding
#
# Forked and modified by Wojtek Galaj
#
# Works with angular 1.5.x

app = angular.module('ngOnboarding', [])

app.provider 'ngOnboardingDefaults', ->
  options: {
    overlay: true,
    overlayOpacity: 0.6,
    overlayClass: 'onboarding-overlay',
    popoverClass: 'onboarding-popover',
    titleClass: 'onboarding-popover-title',
    contentClass: 'onboarding-popover-content',
    arrowClass: 'onboarding-arrow',
    buttonContainerClass: 'onboarding-button-container',
    buttonClass: 'onboarding-button',
    acceptTourButtonClass: 'onboarding-accept',
    dontAccetpTourButtonClass: 'onboarding-reject',
    showButtons: true,
    nextButtonText: 'Next &rarr;',
    previousButtonText: '&larr; Previous',
    showDoneButton: true,
    doneButtonText: 'Done',
    showCloseButton: true,
    closeButtonClass: 'onboarding-close-button',
    closeButtonText: 'X',
    stepClass: 'onboarding-step-info',
    showStepInfo: true
  }
  $get: ->
    @options

  set: (keyOrHash, value) ->
    if typeof(keyOrHash) == 'object'
      for k, v of keyOrHash
        @options[k] = v
    else
      @options[keyOrHash] = value

app.directive 'onboardingPopover', ['ngOnboardingDefaults', '$sce', '$timeout', '$filter', (ngOnboardingDefaults, $sce, $timeout, $filter) ->
  restrict: 'E'
  scope:
    enabled: '='
    steps: '='
    onFinishCallback: '<onFinishCallback'
    index: '=stepIndex'
  replace: true
  link: (scope, element, attrs) ->
    # Important Variables
    curStep = null
    translate = $filter('translate')
    attributesToClear = ['title', 'top', 'right', 'bottom', 'left', 'width', 'height', 'position']
    scope.stepCount = scope.steps.length

    # Button Actions
    scope.next = -> scope.index = scope.index + 1
    scope.previous = -> scope.index = scope.index - 1
    scope.close = (dontShowAnyMore) ->
      scope.enabled = false
      setupOverlay(false)
      if scope.onFinishCallback
        scope.onFinishCallback(dontShowAnyMore)

    # Watch for changes in the current step index
    scope.$watch 'index', (newVal, oldVal) ->
      if newVal == null
        scope.enabled = false
        setupOverlay(false)
        return

      curStep = scope.steps[scope.index]

      if curStep.preStep
        curStep.preStep()

      $timeout(() ->
        # Set step variables to the scope
        scope.finalStep = curStep.finalStep
        scope.acceptTourStep = curStep.acceptTour
        scope.doneButtonText = curStep.doneButtonText || scope.doneButtonText
        scope.doneButtonClass = curStep.doneButtonClas
        scope.lastStep = (scope.index + 1 == scope.steps.length)
        scope.showNextButton = (scope.index + 1 < scope.steps.length)
        scope.showPreviousButton = (scope.index > 0)
        for attr in attributesToClear
          scope[attr] = null
        for k, v of ngOnboardingDefaults
          if curStep[k] == undefined
            scope[k] = v
        for k, v of curStep
          scope[k] = v

        # Allow some variables to include html
        scope.description = $sce.trustAsHtml(translate(scope.description))
        scope.nextButtonText = $sce.trustAsHtml(translate(scope.nextButtonText))
        scope.previousButtonText = $sce.trustAsHtml(translate(scope.previousButtonText))
        scope.doneButtonText = $sce.trustAsHtml(translate(scope.doneButtonText))
        scope.closeButtonText = $sce.trustAsHtml(translate(scope.closeButtonText))
        setupOverlay()
        setupPositioning()
      )


    setupOverlay = (showOverlay=true) ->
      $('.onboarding-focus').removeClass('onboarding-focus')
      if showOverlay
        if curStep['attachTo'] && scope.overlay
          $(curStep['attachTo']).addClass('onboarding-focus')
          if curStep['alsoHighlight']
            $(curStep['alsoHighlight']).addClass('onboarding-focus')

    setupPositioning = ->
      attachTo = curStep['attachTo']
      scope.position = curStep['position']
      xMargin = 15
      yMargin = 15
      if attachTo
        # SET X POSITION
        unless scope.left || scope.right
          left = null
          right = null
          if scope.position == 'right'
            left = $(attachTo).offset().left + $(attachTo).outerWidth() + xMargin
          else if scope.position == 'left'
            right = $(window).width() - $(attachTo).offset().left + xMargin
          else if scope.position == 'top' || scope.position == 'bottom'
            left = $(attachTo).offset().left
          if curStep['xOffset']
            left = left + curStep['xOffset'] if left != null
            right = right - curStep['xOffset'] if right != null
          scope.left = left
          scope.right = right

        # SET Y POSITION
        unless scope.top || scope.bottom
          top = null
          bottom = null
          if scope.position == 'left' || scope.position == 'right'
            top = $(attachTo).offset().top
          else if scope.position == 'bottom'
            top = $(attachTo).offset().top + $(attachTo).outerHeight() + yMargin
          else if scope.position == 'top'
            bottom = $(window).height() - $(attachTo).offset().top + yMargin


          if curStep['yOffset']
            top = top + curStep['yOffset'] if top != null
            bottom = bottom - curStep['yOffset'] if bottom != null
          scope.top = top
          scope.bottom = bottom

      if scope.position && scope.position.length
        scope.positionClass = "onboarding-#{scope.position}"
      else
        scope.positionClass = null

    if scope.steps.length && !scope.index
      scope.index = 0

  template: """
              <div class='onboarding-container' ng-show='enabled'>
                <div class='{{overlayClass}}' ng-style='{opacity: overlayOpacity}', ng-show='overlay'></div>
                <div class='{{popoverClass}} {{positionClass}}' ng-style="{width: width + 'px', height: height + 'px', left: left + 'px', top: top + 'px', right: right + 'px', bottom: bottom + 'px'}">
                  <div class='{{arrowClass}}'></div>
                  <h3 class='{{titleClass}}' ng-show='title' ng-bind='title'></h3>
                  <a href='' ng-if='showCloseButton' ng-click='close(true)' class='{{closeButtonClass}}' ng-bind-html='closeButtonText'></a>

                  <div ng-if='acceptTourStep' class='onboarding-accept-holder'>
                    <div translate ng-bind-html='description'></div>
                    <button ng-click='next()' class='{{buttonClass}} {{acceptTourButtonClass}}'>{{acceptTourStep.ok | translate}}</button>
                    <button ng-click='close(true)' class='{{buttonClass}} {{dontAccetpTourButtonClass}}'>{{acceptTourStep.ko | translate}}</button>
                    <p>{{acceptTourStep.disclaimer | translate}}</p>
                  </div>

                  <div ng-if='!acceptTourStep'>
                    <div class='{{contentClass}}'>
                      <p translate ng-bind-html='description'></p>
                    </div>
                    <div class='{{buttonContainerClass}}' ng-show='showButtons'>
                      <span ng-show='showStepInfo' class='{{stepClass}}'>Step {{index + 1}} of {{stepCount}}</span>
                      <button href='' ng-click='previous()' ng-show='showPreviousButton' class='{{buttonClass}}'>{{previousButtonText | translate}}</button>
                      <button href='' ng-click='next()' ng-show='showNextButton' class='{{buttonClass}}'>{{nextButtonText | translate}}</button>
                      <button href='' ng-click='close(finalStep)' ng-if='showDoneButton && lastStep' class='{{buttonClass}} {{doneButtonClass}}'>{{doneButtonText | translate}}</button>
                    </div>
                  </div>

                </div>
              </div>
            """
]
