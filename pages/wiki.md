---
layout: page
title: Wiki
description: 人越学越觉得自己无知
keywords: 维基, Wiki
comments: false
menu: 维基
permalink: /wiki/
---

<blockquote>
    <a id="poem">今日诗词</a>
    <a id="author"></a>
</blockquote>
<script src="https://sdk.jinrishici.com/v2/browser/jinrishici.js" charset="utf-8"></script>
<script type="text/javascript">
    jinrishici.load(function(result) {
      var poem =  result.data.content;
      var author = "——" + result.data.origin.author +"《" + result.data.origin.title + "》";
      document.getElementById("poem").innerHTML = poem;
      document.getElementById("author").innerHTML = author;
    })
</script>

<ul class="listing">
{% for wiki in site.wiki %}
{% if wiki.title != "Wiki Template" and wiki.topmost == true %}
<li class="listing-item"><a href="{{ site.url }}{{ wiki.url }}"><span class="top-most-flag">[置顶]</span>{{ wiki.title }}</a></li>
{% endif %}
{% endfor %}
{% for wiki in site.wiki %}
{% if wiki.title != "Wiki Template" and wiki.topmost != true %}
<li class="listing-item"><a href="{{ site.url }}{{ wiki.url }}">{{ wiki.title }}<span style="font-size:12px;color:red;font-style:italic;">{%if wiki.layout == 'mindmap' %}  mindmap{% endif %}</span></a></li>
{% endif %}
{% endfor %}
</ul>
