---
layout: page
title: About
description: 
keywords: nineholic
comments: true
menu: 关于
permalink: /about/
---

路漫漫其修远兮，吾将上下而求索。

## Contact

{% for website in site.data.social %}
* {{ website.sitename }}：[{{ website.name }}]({{ website.url }})
{% endfor %}

## Skill Keywords

{% for skill in site.data.skills %}
### {{ skill.name }}
<div class="btn-inline">
{% for keyword in skill.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
