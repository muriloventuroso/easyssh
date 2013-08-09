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

        if (!languages.is(e.target) && languages.has(e.target).length === 0) {
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
});
