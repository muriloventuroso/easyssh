$(function() {
    $('#languages').change(function () {
        window.location.href = $(this).val();
    });
    $('a.screenshot').colorbox({
        rel:'gal',
        maxWidth:'100%',
        maxHeight:'100%',
        width:'100%',
        height:'100%',
        current: '{current}/{total}',
    });
});
