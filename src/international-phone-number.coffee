# Author Marek Pietrucha
# https://github.com/mareczek/international-phone-number

"use strict"
angular.module("internationalPhoneNumber", []).directive 'internationalPhoneNumber', () ->

  restrict:   'A'
  require: '^ngModel'
  scope: true

  link: (scope, element, attrs, ctrl) ->

    read = () ->
      if angular.isDefined attrs.countryModel
        scope.$eval(attrs.countryModel + '=' + element.intlTelInput("getSelectedCountryData").dialCode)
      ctrl.$setViewValue element.val()

    handleWhatsSupposedToBeAnArray = (value) ->
      if typeof(value) == "object"
        value
      else
        value.toString().replace(/[ ]/g, '').split(',')

    options =
      autoFormat:         true
      autoHideDialCode:   true
      defaultCountry:     ''
      nationalMode:       false
      numberType:         ''
      onlyCountries:      undefined
      preferredCountries: ['us', 'gb']
      responsiveDropdown: false
      utilsScript:        ""

    angular.forEach options, (value, key) ->
      return unless attrs.hasOwnProperty(key) and angular.isDefined(attrs[key])
      option = attrs[key]
      if key == 'preferredCountries'
        options.preferredCountries = handleWhatsSupposedToBeAnArray option
      else if key == 'onlyCountries'
        options.onlyCountries = handleWhatsSupposedToBeAnArray option
      else if typeof(value) == "boolean"
        options[key] = (option == "true")
      else
        options[key] = option

    element.intlTelInput(options)

    unless options.utilsScript
      element.intlTelInput('loadUtils', '/bower_components/intl-tel-input/lib/libphonenumber/build/utils.js')

    ctrl.$parsers.push (value) ->
      return value if !value
      value.replace(/[^\d]/g, '')

    ctrl.$parsers.push (value) ->
      if value
        ctrl.$setValidity 'international-phone-number', element.intlTelInput("isValidNumber")
      else
        value = ''
        delete ctrl.$error['international-phone-number']
      value

    element.on 'blur keyup change', (event) ->
      scope.$apply read

    element.on '$destroy', () ->
      element.off 'blur keyup change'
