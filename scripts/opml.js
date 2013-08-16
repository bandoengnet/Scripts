

function opml2html()  
{
    this.export_template = '<html><title>Opml export</title><body>{INNERHTML}</body></html>';
    this.html_template = '<h1>{OPMLTITLE}</h1>\n<ul>{ITEMS}</ul>';
    this.rss_template = '<li>[<a href="{XMLURL}">RSS</a>] <a href="{HTMLURL}">{TITLE}</a></li>\n';
    this.folder_template_start = '<li>{TITLE}\n<ul>\n';
    this.folder_template_end = '</ul></li>\n';
    this.parse = function(opml) {

        var doc;
        // code for IE
        if (window.ActiveXObject) {
            doc = new ActiveXObject("Microsoft.XMLDOM");
            doc.async = false;
            doc.loadXML(opml);
        // code for Mozilla, Firefox, Opera, etc.
        } else {
            var parser = new DOMParser();
            doc = parser.parseFromString(opml,"text/xml");
        }


        var html = this.parseLevel(doc);
        
        var opml_title = doc.getElementsByTagName('title')[0].firstChild.nodeValue;
        html = this.html_template.replace(/{ITEMS}/, html).replace(/{OPMLTITLE}/, opml_title);
        return html;

    };

    this.parseLevel = function (doc,html)
    {
        if (html === undefined)
            html = '';

        for (var i = 0, max = doc.childNodes.length; i < max; i++) 
        {

            var node = doc.childNodes[i];
            if (node.nodeName == 'outline')
            {
                var type = node.getAttribute('type');
                if (type && type == 'rss')
                {
                    
                    title   = node.getAttribute('title');
                    htmlurl = node.getAttribute('htmlUrl');
                    xmlurl  = node.getAttribute('xmlUrl');
                    html += this.rss_template.replace(/{TITLE}/, title).replace(/{HTMLURL}/, htmlurl).replace(/{XMLURL}/, xmlurl);

                }else
                {
                    title   = node.getAttribute('title');
                    html += this.folder_template_start.replace(/{TITLE}/, title);
                    html = this.parseLevel(node,html);
                    html += this.folder_template_end;
                }
            }else
            {
                html = this.parseLevel(node,html);
            }
        }

        return html;
    };

    this.export = function(opml)
    {
        var innerHtml = this.parse(opml);

        var html = this.export_template.replace(/{INNERHTML}/, innerHtml);
        return html;
    };

    this.saveHtml = function(html)
    {
        var uriContent = "data:application/octet-stream," + encodeURIComponent(html);
        var myWindow = window.open(uriContent, "OPML export");
        myWindow.focus();
    };

    this.exportAndSave = function(opml)
    {
        var html = this.export(opml);
        this.saveHtml(html);
    }

}

var opml2htmlParser = new opml2html();

