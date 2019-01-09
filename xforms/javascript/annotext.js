/// annotext.js by KANZAKI, Masahide. ver 1.5, 2017-03-12. MIT license.
AnnoText = function(){
	this.basecontext[1][this.anbase.pfx] = this.anbase.uri;
};
AnnoText.prototype = {
	anbase: {"pfx": "anbase", "uri": "http://purl.org/net/ld/annot/masaka/"},
	basecontext : [
		"http://www.w3.org/ns/anno.jsonld",
		{}
	],
	whoswho: {},
	preflang: null,
	gettext: function(an, limit){
		if(typeof(an.bodyValue) !== "undefined"){
			return this.formattext(an.bodyValue, limit, an);
		}else if(an.body && typeof(an.body.value) !== "undefined"){
			return this.formattext(an.body.value, (limit || an.body.format ||
				 (an.body.type ? an.body.type.toLowerCase() : null)), an);
		}else if(an.description){
			return this.formattext(an.description, limit);
		}else{
			return "";
		}
	},
	formattext: function(text, fmt, an){
		if(typeof(text) === "object") text = this.get_lang_text(text);
		if(typeof(fmt) === "number"){
			text = text.replace(/<.*?>/g, "").replace(/</g, "&lt;");
			return (text.length > fmt) ? text.substr(0, fmt-2) + "..." : text;
		}else{
			switch(fmt){
			case "text/html":
				return text.replace(/<script/g, "&lt;script");
			case "text/xml":
				return text;
			default:
				if(fmt){
					var mimetop = fmt.substr(0, 5);
					if(mimetop === "image"){
						return "<img alt='' src='" + text + "'/>";
					}else if(["audio","video"].indexOf(mimetop) > -1){
						return "<" + mimetop + " alt='' controls src='" + text + "'/>";
					}
				}
				text =text.replace(/</g, "&lt;");
				if(an){
					var dsid = " data-source=\"" + an.target.source + "\" data-anid=\"" + an.id + "\"";
					if(an.hasPrev) text = text.replace(/^(\.\.\.|…)/, "<a href=\"#!prev\"" + dsid + " title=\"cont'd from prev\">...</a> ");
					if(an.hasNext) text = text.replace(/(\.\.\.|…)$/, " <a href=\"#!next\"" + dsid + "title=\"cont'd on next\">...</a>");
				}
				return this.md2link(text);
			}
		}
	},
	get_lang_text: function(text){
		if(Mut) return Mut.str.lang_val(text);
		if(!this.preflang){
			var lang = navigator.userLanguage || navigator.language;
			this.preflang = lang.substr(0,2).toLowerCase();
		}
		var en, none, other = [];
		for(var lang in text){
			if(lang.substr(0,2) === this.preflang) return text[lang].join(";");
			else if(lang.substr(0,2) === "en") en = text[lang].join(";");
			else if(lang === "@none") none = text[lang].join(";");
			else other.push(text[lang].join(";"));
		}
		return en || none || other.shift();
	},
	settext: function(an){
		if(an){
			if(an.hasPrev) an.text = an.text.replace(/^<a href="#!prev".*?<\/a>/, "...");
			if(an.hasNext) an.text = an.text.replace(/<a href="#!next".*?<\/a>$/, "...");
		}
		return this.link2md(an.text);
	},
	md2link: function(text){
		return this.mdhilite(text)
		.replace(/!\[([^\]]+)\]\(([^\)]+)\)/g, function(txt, alt, url){
			var elt, attr = " alt='" + alt + "'";
			if(url.match(/\.mp4$/)){elt = "video"; attr += " controls";}
			else if(url.match(/\.mp3$/)){elt = "audio"; attr += " controls";}
			else elt = "img";
			return "<" + elt + attr + " src='" + url + "'/>";
		})
		.replace(/\[([^\]]+)\]\(([^\)]+)\)/g, "<a href='$2'>$1</a>");
	},
	mdhilite: function(text){
		return text
		.replace(/\*\*([^\*]+)\*\*/, "<strong>$1</strong>")
		.replace(/\b_([^_]+)_\b/, "<em>$1</em>")
		.replace(/`([^`]+)`/, "<code>$1</code>");
	},
	link2md: function(text){
		if(text === "") return text;
		return text
		.replace(/<(img|video|audio) alt=['"](.*?)['"].* src=['"](.*?)['"]\/?>/g, "![$2]($3)")
		.replace(/<a href=['"](.*?)['"]>(.*?)<\/a>/g, "[$2]($1)");
	},
	getUTCdateTime: function(val){
		var date = val ? new Date(val) : new Date();
		return date.getUTCFullYear() + '-' +
		('0' + (date.getUTCMonth() + 1)).slice(-2) + '-' +
		('0' + date.getUTCDate()).slice(-2) + 'T' +
		('0' + date.getUTCHours()).slice(-2) + ':' +
		('0' + date.getMinutes()).slice(-2) + ':' +
		('0' + date.getSeconds()).slice(-2) + 'Z';
	},
	getLastUripart: function(uri){
		uri.match(/[\/#]([^\/#]+)$/);
		return RegExp.$1;
	},
	getCreator: function(an){
		if(!an.creator){
			return this.registWhoswho("anonymous");
		}else if(typeof(an.creator) === "string"){
			return this.registWhoswho(an.creator);
		}else{
			var uri = an.creator.id || an.creator["@id"] || an.creator.homepage || null;
			var id = "_" + uri;
			var name = an.creator.name || an.creator.nickname || an.creator.displayName || null;
			if(!id && name) id = name;
			if(!id) return this.registWhoswho("unknown");
			if(!this.whoswho[id]){
				this.whoswho[id] = {
					"meta": an.creator,
					"dispname": (name ? name : "\u200B"+this.getLastUripart(id))
				};
			}
			if(this.whoswho[uri] && this.whoswho[uri].dispname.substr(0,1)==="\u200B" && name){
				this.whoswho[uri].dispname = name;
			}
			return id;
		}
	},
	registWhoswho: function(user){
		if(!this.whoswho[user]){
			this.whoswho[user] = {"meta": user==="anonymous" || user==="unknown" ? "" : user};
			this.whoswho[user].dispname = user.match(/^(https?|urn):/) ?
			"\u200B"+this.getLastUripart(user) : user;
		}
		return user;
	},
	setCreator: function(id){
		if(!this.whoswho[id] || id==="anonymous") return "";
		return this.whoswho[id].meta;
	},
	
	getDate: function(an, type){
		var dval = type ? an[type] : an.created;
		if(!dval) return "";
		return new Date(dval).toLocaleDateString();
	},
	md5: function(str){
		var md5 = new yjdMd5();
		return md5.GetOfString(str);
	},
	crc32: function(str){
		var crcTable = this.ct(), crc = 0 ^ (-1);
		for (var i = 0; i < str.length; i++ ) crc = (crc >>> 8) ^ crcTable[(crc ^ str.charCodeAt(i)) & 0xFF];
		return (crc ^ (-1)) >>> 0;
	},
	ct: function(){
		var c, crcTable = [];
		for(var n =0; n < 256; n++){
			c = n;
			for(var k =0; k < 8; k++) c = ((c&1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1));
			crcTable[n] = c >>> 0;
		}
		return crcTable;
	},
};
var at = new AnnoText();


var yjdMd5 = function() {
	this.au32_state = new Uint32Array(4);
	this.au32_buffer = null;
	this.n_blocks = 0;
	
	this.Init = function() {
		this.au32_state[0] = 0x67452301;
		this.au32_state[1] = 0xefcdab89;
		this.au32_state[2] = 0x98badcfe;
		this.au32_state[3] = 0x10325476;
	};
	
	this.Transform = function() {
		var a, b, c, d;
		var x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x10, x11, x12, x13, x14, x15;
		var n_idx = 0;
		for( var i=0; i<this.n_blocks; i++) {
			a = this.au32_state[0];
			b = this.au32_state[1];
			c = this.au32_state[2];
			d = this.au32_state[3];
			
			x00 = this.au32_buffer[n_idx++];
			x01 = this.au32_buffer[n_idx++];
			x02 = this.au32_buffer[n_idx++];
			x03 = this.au32_buffer[n_idx++];
			x04 = this.au32_buffer[n_idx++];
			x05 = this.au32_buffer[n_idx++];
			x06 = this.au32_buffer[n_idx++];
			x07 = this.au32_buffer[n_idx++];
			x08 = this.au32_buffer[n_idx++];
			x09 = this.au32_buffer[n_idx++];
			x10 = this.au32_buffer[n_idx++];
			x11 = this.au32_buffer[n_idx++];
			x12 = this.au32_buffer[n_idx++];
			x13 = this.au32_buffer[n_idx++];
			x14 = this.au32_buffer[n_idx++];
			x15 = this.au32_buffer[n_idx++];
			
			a += ((b & c) | (~b & d)) + x00 + 0xd76aa478;	a = ((a << 7) | (a >>> 25)) + b;
			d += ((a & b) | (~a & c)) + x01 + 0xe8c7b756;	d = ((d << 12) | (d >>> 20)) + a;
			c += ((d & a) | (~d & b)) + x02 + 0x242070db;	c = ((c << 17) | (c >>> 15)) + d;
			b += ((c & d) | (~c & a)) + x03 + 0xc1bdceee;	b = ((b << 22) | (b >>> 10)) + c;
			a += ((b & c) | (~b & d)) + x04 + 0xf57c0faf;	a = ((a << 7) | (a >>> 25)) + b;
			d += ((a & b) | (~a & c)) + x05 + 0x4787c62a;	d = ((d << 12) | (d >>> 20)) + a;
			c += ((d & a) | (~d & b)) + x06 + 0xa8304613;	c = ((c << 17) | (c >>> 15)) + d;
			b += ((c & d) | (~c & a)) + x07 + 0xfd469501;	b = ((b << 22) | (b >>> 10)) + c;
			a += ((b & c) | (~b & d)) + x08 + 0x698098d8;	a = ((a << 7) | (a >>> 25)) + b;
			d += ((a & b) | (~a & c)) + x09 + 0x8b44f7af;	d = ((d << 12) | (d >>> 20)) + a;
			c += ((d & a) | (~d & b)) + x10 + 0xffff5bb1;	c = ((c << 17) | (c >>> 15)) + d;
			b += ((c & d) | (~c & a)) + x11 + 0x895cd7be;	b = ((b << 22) | (b >>> 10)) + c;
			a += ((b & c) | (~b & d)) + x12 + 0x6b901122;	a = ((a << 7) | (a >>> 25)) + b;
			d += ((a & b) | (~a & c)) + x13 + 0xfd987193;	d = ((d << 12) | (d >>> 20)) + a;
			c += ((d & a) | (~d & b)) + x14 + 0xa679438e;	c = ((c << 17) | (c >>> 15)) + d;
			b += ((c & d) | (~c & a)) + x15 + 0x49b40821;	b = ((b << 22) | (b >>> 10)) + c;
			a += ((b & d) | (c & ~d)) + x01 + 0xf61e2562;	a = ((a << 5) | (a >>> 27)) + b;
			d += ((a & c) | (b & ~c)) + x06 + 0xc040b340;	d = ((d << 9) | (d >>> 23)) + a;
			c += ((d & b) | (a & ~b)) + x11 + 0x265e5a51;	c = ((c << 14) | (c >>> 18)) + d;
			b += ((c & a) | (d & ~a)) + x00 + 0xe9b6c7aa;	b = ((b << 20) | (b >>> 12)) + c;
			a += ((b & d) | (c & ~d)) + x05 + 0xd62f105d;	a = ((a << 5) | (a >>> 27)) + b;
			d += ((a & c) | (b & ~c)) + x10 + 0x2441453;	d = ((d << 9) | (d >>> 23)) + a;
			c += ((d & b) | (a & ~b)) + x15 + 0xd8a1e681;	c = ((c << 14) | (c >>> 18)) + d;
			b += ((c & a) | (d & ~a)) + x04 + 0xe7d3fbc8;	b = ((b << 20) | (b >>> 12)) + c;
			a += ((b & d) | (c & ~d)) + x09 + 0x21e1cde6;	a = ((a << 5) | (a >>> 27)) + b;
			d += ((a & c) | (b & ~c)) + x14 + 0xc33707d6;	d = ((d << 9) | (d >>> 23)) + a;
			c += ((d & b) | (a & ~b)) + x03 + 0xf4d50d87;	c = ((c << 14) | (c >>> 18)) + d;
			b += ((c & a) | (d & ~a)) + x08 + 0x455a14ed;	b = ((b << 20) | (b >>> 12)) + c;
			a += ((b & d) | (c & ~d)) + x13 + 0xa9e3e905;	a = ((a << 5) | (a >>> 27)) + b;
			d += ((a & c) | (b & ~c)) + x02 + 0xfcefa3f8;	d = ((d << 9) | (d >>> 23)) + a;
			c += ((d & b) | (a & ~b)) + x07 + 0x676f02d9;	c = ((c << 14) | (c >>> 18)) + d;
			b += ((c & a) | (d & ~a)) + x12 + 0x8d2a4c8a;	b = ((b << 20) | (b >>> 12)) + c;
			a += (b ^ c ^ d) + x05 + 0xfffa3942;	a = ((a << 4) | (a >>> 28)) + b;
			d += (a ^ b ^ c) + x08 + 0x8771f681;	d = ((d << 11) | (d >>> 21)) + a;
			c += (d ^ a ^ b) + x11 + 0x6d9d6122;	c = ((c << 16) | (c >>> 16)) + d;
			b += (c ^ d ^ a) + x14 + 0xfde5380c;	b = ((b << 23) | (b >>> 9)) + c;
			a += (b ^ c ^ d) + x01 + 0xa4beea44;	a = ((a << 4) | (a >>> 28)) + b;
			d += (a ^ b ^ c) + x04 + 0x4bdecfa9;	d = ((d << 11) | (d >>> 21)) + a;
			c += (d ^ a ^ b) + x07 + 0xf6bb4b60;	c = ((c << 16) | (c >>> 16)) + d;
			b += (c ^ d ^ a) + x10 + 0xbebfbc70;	b = ((b << 23) | (b >>> 9)) + c;
			a += (b ^ c ^ d) + x13 + 0x289b7ec6;	a = ((a << 4) | (a >>> 28)) + b;
			d += (a ^ b ^ c) + x00 + 0xeaa127fa;	d = ((d << 11) | (d >>> 21)) + a;
			c += (d ^ a ^ b) + x03 + 0xd4ef3085;	c = ((c << 16) | (c >>> 16)) + d;
			b += (c ^ d ^ a) + x06 + 0x4881d05;	b = ((b << 23) | (b >>> 9)) + c;
			a += (b ^ c ^ d) + x09 + 0xd9d4d039;	a = ((a << 4) | (a >>> 28)) + b;
			d += (a ^ b ^ c) + x12 + 0xe6db99e5;	d = ((d << 11) | (d >>> 21)) + a;
			c += (d ^ a ^ b) + x15 + 0x1fa27cf8;	c = ((c << 16) | (c >>> 16)) + d;
			b += (c ^ d ^ a) + x02 + 0xc4ac5665;	b = ((b << 23) | (b >>> 9)) + c;
			a += (c ^ (b | ~d)) + x00 + 0xf4292244;	a = ((a << 6) | (a >>> 26)) + b;
			d += (b ^ (a | ~c)) + x07 + 0x432aff97;	d = ((d << 10) | (d >>> 22)) + a;
			c += (a ^ (d | ~b)) + x14 + 0xab9423a7;	c = ((c << 15) | (c >>> 17)) + d;
			b += (d ^ (c | ~a)) + x05 + 0xfc93a039;	b = ((b << 21) | (b >>> 11)) + c;
			a += (c ^ (b | ~d)) + x12 + 0x655b59c3;	a = ((a << 6) | (a >>> 26)) + b;
			d += (b ^ (a | ~c)) + x03 + 0x8f0ccc92;	d = ((d << 10) | (d >>> 22)) + a;
			c += (a ^ (d | ~b)) + x10 + 0xffeff47d;	c = ((c << 15) | (c >>> 17)) + d;
			b += (d ^ (c | ~a)) + x01 + 0x85845dd1;	b = ((b << 21) | (b >>> 11)) + c;
			a += (c ^ (b | ~d)) + x08 + 0x6fa87e4f;	a = ((a << 6) | (a >>> 26)) + b;
			d += (b ^ (a | ~c)) + x15 + 0xfe2ce6e0;	d = ((d << 10) | (d >>> 22)) + a;
			c += (a ^ (d | ~b)) + x06 + 0xa3014314;	c = ((c << 15) | (c >>> 17)) + d;
			b += (d ^ (c | ~a)) + x13 + 0x4e0811a1;	b = ((b << 21) | (b >>> 11)) + c;
			a += (c ^ (b | ~d)) + x04 + 0xf7537e82;	a = ((a << 6) | (a >>> 26)) + b;
			d += (b ^ (a | ~c)) + x11 + 0xbd3af235;	d = ((d << 10) | (d >>> 22)) + a;
			c += (a ^ (d | ~b)) + x02 + 0x2ad7d2bb;	c = ((c << 15) | (c >>> 17)) + d;
			b += (d ^ (c | ~a)) + x09 + 0xeb86d391;	b = ((b << 21) | (b >>> 11)) + c;
			
			this.au32_state[0] += a;
			this.au32_state[1] += b;
			this.au32_state[2] += c;
			this.au32_state[3] += d;
		}
	};
	
	this.Padding = function(n_length) {
		var n_mod = n_length % 4;
		var n_idx = (n_length - n_mod) / 4;
		this.au32_buffer[n_idx++] |= (0x80 << (n_mod * 8));
		while(n_idx % 16!=14) {
			this.au32_buffer[n_idx++] = 0;
		}
		var n_bit_len = n_length * 8;
		this.au32_buffer[n_idx++] = n_bit_len;
		this.au32_buffer[n_idx++] = Math.floor(n_bit_len / 4294967296);
		this.n_blocks = n_idx / 16;
	};
	
	this.SetString = function(s_str) {
		var n_max_bytes = s_str.length * 4;
		var n_buff_size = (Math.floor((n_max_bytes + 8) / 64) + 1) * 16;
		this.au32_buffer = new Uint32Array(n_buff_size);
		var n_len = s_str.length;
		var n_idx = 0, n_shift = 0, n_code;
		for(var i=0; i<n_len; i++) {
			n_code = s_str.charCodeAt(i);
			if(n_code < 0x80) {
				this.au32_buffer[n_idx] |= (n_code << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
			} else if(n_code < 0x800) {
				this.au32_buffer[n_idx] |= ((0xc0 | (n_code >>> 6)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | (n_code & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
			} else if(n_code < 0xd800 || n_code >= 0xe000) {
				this.au32_buffer[n_idx] |= ((0xe0 | (n_code >>> 12)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | ((n_code>>>6) & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | (n_code & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
			} else {
				this.au32_buffer[n_idx] |= ((0xf0 | (n_code >>>18)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | ((n_code>>>12) & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | ((n_code>>>6) & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
				this.au32_buffer[n_idx] |= ((0x80 | (n_code & 0x3f)) << n_shift);	(n_shift==24)? (n_idx++, n_shift=0): n_shift += 8;
			}
		}
		return n_idx * 4 + n_shift / 8;
	};

	
	this.GetValueByStr = function() {
		var n_reg, c0, c1, c2, c3, c4, c5, c6, c7;
		var s_str = '';
		for(var i=0; i<4; i++) {
			n_reg = this.au32_state[i];
			c0 = (n_reg >>> 4) & 0xF;
			c1 = n_reg & 0xF;
			c2 = (n_reg >>> 12) & 0xF;
			c3 = (n_reg >>> 8) & 0xF;
			c4 = (n_reg >>> 20) & 0xF;
			c5 = (n_reg >>> 16) & 0xF;
			c6 = (n_reg >>> 28) & 0xF;
			c7 = (n_reg >>> 24) & 0xF;
 			s_str += c0.toString(16) + c1.toString(16) + c2.toString(16) + c3.toString(16)
 					+ c4.toString(16) + c5.toString(16) + c6.toString(16) + c7.toString(16);
		}
		return s_str;
	};
	
	this.GetOfString = function(s_str) {
		this.Init();
		var n_bytes = this.SetString(s_str);
		this.Padding(n_bytes);
		this.Transform();
		return this.GetValueByStr();
	};
};
