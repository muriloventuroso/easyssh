$(function () {
    $('.language').click(function () {
        var $language = $('.language');
        var position = $language.position();
        var width = $language.outerWidth();
        var height = $language.outerHeight();
        $('.languages').toggle().css({
            left: position.left + width - $('.languages').outerWidth(),
            top: position.top + height
        });
    });
    $(document).mouseup(function (e) {
        var languages = $('.languages');
        var language = $('.language');

        if (language.is(e.target) || language.has(e.target).length > 0) {
            return;
        } else if (!languages.is(e.target) && languages.has(e.target).length === 0) {
            languages.hide();
        }
    });
    $('.screenshot').colorbox({
        rel: 'gal',
        maxWidth: '100%',
        maxHeight: '100%',
        width: '100%',
        height: '100%',
        current: '{current}/{total}'
    });
    $('[data-toggle="tooltip"]').tooltip()
    $('#id_vat_0').on('change', function() {
        var value = $(this).val();
        if (value != '') {
            var country = $('#id_country option[value="' + value + '"]');
            country.prop('selected', true);
        }
    });
    $('#id_vat_0,#id_vat_1').on('focusout', function() {
        var country = $('#id_vat_0').val();
        var code = $('#id_vat_1').val();
        if (country && code) {
            var payload = {
                vat: country + code,
                payment: $('input[name="payment"]').val(),
                csrfmiddlewaretoken: $('input[name="csrfmiddlewaretoken"]').val(),
            };
            $.post('/js/vat/', payload , function(data) {
                if (data.valid) {
                    $('input[name="name"]').val(data.name);
                    var parts = data.address.trim().split("\n");
                    $('input[name="address"]').val(parts[0]);
                    $('input[name="city"]').val(parts[parts.length - 1]);
                }
            });
        }
    });
});
