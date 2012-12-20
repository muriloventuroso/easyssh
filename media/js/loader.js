$(function() {
    $("div.tabs").tabs({
        ajaxOptions: {
            error: function(xhr, status, index, anchor) {
                $(anchor.hash).html("AJAX request to load this content has failed!");
            }
        },
        cache: true,
        load: function (e, ui) {
            $(ui.panel).find(".tab-loading").remove();
        },
        show: function (e, ui) {
            var $panel = $(ui.panel);

            if ($panel.is(":empty")) {
                $panel.append("<div class='tab-loading'>" + "Loading..." + "</div>");
            }
        },
    });
    $('a.language').button().css({position: 'absolute', top: '1em', right: '1em'}).click(function () {
        $('<ul>' +
            '<li><a href="/index.php?lang=en">English</a></li>' +
            '<li><a href="/index.php?lang=cs">Česky</a></li>' +
            '<li><a href="/index.php?lang=da">Dansk</a></li>' +
            '<li><a href="/index.php?lang=fr">Français</a></li>' +
            '<li><a href="/index.php?lang=el">Ελληνικά</a></li>' +
            '<li><a href="/index.php?lang=es">Español</a></li>' +
//            '<li><a href="/index.php?lang=gl">Galego</a></li>' +
//            '<li><a href="/index.php?lang=pl">Polski</a></li>' +
            '<li><a href="/index.php?lang=pt_BR">Português brasileiro</a></li>' +
            '<li><a href="/index.php?lang=tr">Türkçe</a></li>' +
            '<li><a href="/index.php?lang=zh_CN">中文</a></li>' +
            '</ul>').dialog({title: 'Choose language'});
    });

    $('#news-content').load('/export/weblate/');
});
