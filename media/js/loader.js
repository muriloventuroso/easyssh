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
            '<li><a href="index.html">English</a></li>' +
            '<li><a href="index.cs.html">Česky</a></li>' +
            '<li><a href="index.fr.html">Français</a></li>' +
            '<li><a href="index.pl.html">Polski</a></li>' +
            '<li><a href="index.tr.html">Türkçe</a></li>' +
            '</ul>').dialog({title: 'Choose language'});
    });

    $('#news-content').load('/export/weblate/');
});
