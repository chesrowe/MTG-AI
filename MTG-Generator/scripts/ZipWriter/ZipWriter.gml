/// @lint nullToAny true
// Feather disable all
globalvar mq_zip_std_Date;mq_zip_std_Date=[undefined,undefined];
globalvar mq_zip_std_haxe_Exception;mq_zip_std_haxe_Exception=[undefined,undefined];
globalvar mq_zip_std_haxe_ValueException;mq_zip_std_haxe_ValueException=[undefined,undefined,undefined];
globalvar zip_std_haxe_type_markerValue;zip_std_haxe_type_markerValue=[];
globalvar mt_zip_std_Date;
globalvar mt_zip_std_haxe_class;
globalvar mt_zip_std_haxe_Exception;
globalvar mt_zip_std_haxe_ValueException;
(function(){
mt_zip_std_Date=new zip_std_haxe_class(7,"zip_std_Date");
mt_zip_std_haxe_class=new zip_std_haxe_class(-1,"zip_std_haxe_class");
mt_zip_std_haxe_Exception=new zip_std_haxe_class(8,"zip_std_haxe_Exception");
mt_zip_std_haxe_ValueException=new zip_std_haxe_class(9,"zip_std_haxe_ValueException");
mt_zip_std_haxe_ValueException.superClass=mt_zip_std_haxe_Exception;
})();

function zip_std_Date_create(_year,_month,_day,_hour,_min1,_sec){
	// zip_std_Date_create(year:int, month:int, day:int, hour:int, min:int, sec:int)
	var _this=[mt_zip_std_Date];
	array_copy(_this,1,mq_zip_std_Date,1,1);
	/// @typedef {tuple<any,date:date>} zip_std_Date
	_this[@1]=date_create_datetime(_year,_month+1,_day,_hour,_min1,_sec);
	return _this;
}

function zip_std_Date_now(){
	// zip_std_Date_now()->zip_std_Date
	var _d=zip_std_Date_create(2000,0,1,0,0,0);
	_d[@1]=date_current_datetime();
	return _d;
}

function zip_create(_compressionLevel){
	/// zip_create(compressionLevel:int = -1)
	/// @param {int} [compressionLevel=-1]
	var _this=array_create(4);
	/// @typedef {tuple<buffer:buffer,files:ds_list<ZipEntry>,open:bool,compression_level:int>} zip
	if(_compressionLevel==undefined)_compressionLevel=-1;
	if(false)show_debug_message(argument[0]);
	_this[@2]=true;
	_this[@1]=ds_list_create();
	_this[@0]=buffer_create(128,buffer_grow,1);
	_this[@3]=_compressionLevel;
	return _this;
}

function zip_impl_write(_dst,_src,_srcPos,_srcLen){
	// zip_impl_write(dst:buffer, src:buffer, srcPos:int, srcLen:int)
	var _dstPos=buffer_tell(_dst);
	var _dstNext=_dstPos+_srcLen;
	var _dstSize=buffer_get_size(_dst);
	if(_dstNext>_dstSize){
		while(true){
			_dstSize*=2;
			if(_dstNext<=_dstSize)break;
		}
		buffer_resize(_dst,_dstSize);
	}
	buffer_copy(_src,_srcPos,_srcLen,_dst,_dstPos);
	buffer_seek(_dst,buffer_seek_start,_dstNext);
}

function zip_destroy(_this){
	/// zip_destroy(this:zip)
	/// @param {zip} this
	buffer_delete(_this[0]);
	_this[@0]=-1;
	ds_list_destroy(_this[1]);
	_this[@1]=-1;
	_this[@2]=false;
}

function zip_add_buffer_ext(_this,_path1,_buf,_pos,_len,_compressionLevel){
	/// zip_add_buffer_ext(this:zip, path:string, buf:buffer, pos:int, len:int, ?compressionLevel:int)
	/// @param {zip} this
	/// @param {string} path
	/// @param {buffer} buf
	/// @param {int} pos
	/// @param {int} len
	/// @param {int} ?compressionLevel
	if(false)show_debug_message(argument[4]);
	if(!_this[2])throw zip_std_haxe_Exception_thrown("Zip writer is already finalized.");
	if(_compressionLevel==undefined)_compressionLevel=_this[3];
	var _compress=_compressionLevel!=0;
	var _o=_this[0];
	buffer_write(_o,buffer_s32,67324752);
	buffer_write(_o,buffer_u16,20);
	buffer_write(_o,buffer_u16,2048);
	buffer_write(_o,buffer_u16,(_compress?8:0));
	var _time=zip_std_Date_now();
	buffer_write(_o,buffer_u16,(((date_get_hour(_time[1])<<11)|(date_get_minute(_time[1])<<5))|(date_get_second(_time[1])>>1)));
	buffer_write(_o,buffer_u16,(((date_get_year(_time[1])-1980<<9)|(date_get_month(_time[1])-1+1<<5))|date_get_weekday(_time[1])));
	var _crc=buffer_crc32(_buf,_pos,_len) ^ 0xFFFFFFFF;
	var _cbuf=undefined;
	var _clen=_len;
	if(_compress){
		_cbuf=buffer_compress(_buf,_pos,_len);
		_clen=buffer_get_size(_cbuf)-6;
	}
	buffer_write(_o,buffer_u32,_crc);
	buffer_write(_o,buffer_s32,_clen);
	buffer_write(_o,buffer_s32,_len);
	buffer_write(_o,buffer_u16,string_byte_length(_path1));
	buffer_write(_o,buffer_u16,0);
	buffer_write(_o,buffer_text,_path1);
	var _file=[_path1,_compress,_clen,_len,_crc,_time];
	if(_compress){
		zip_impl_write(_o,_cbuf,2,_clen);
		buffer_delete(_cbuf);
	} else zip_impl_write(_o,_buf,_pos,_len);
	ds_list_add(_this[1],_file);
}

function zip_add_buffer(_this,_path1,_buf,_compressionLevel){
	/// zip_add_buffer(this:zip, path:string, buf:buffer, ?compressionLevel:int)
	/// @param {zip} this
	/// @param {string} path
	/// @param {buffer} buf
	/// @param {int} ?compressionLevel
	if(false)show_debug_message(argument[2]);
	zip_add_buffer_ext(_this,_path1,_buf,0,buffer_get_size(_buf),_compressionLevel);
}

function zip_add_file(_this,_path1,_filePath,_compressionLevel){
	/// zip_add_file(this:zip, path:string, filePath:string, ?compressionLevel:int)
	/// @param {zip} this
	/// @param {string} path
	/// @param {string} filePath
	/// @param {int} ?compressionLevel
	if(false)show_debug_message(argument[2]);
	var _buf=buffer_load(_filePath);
	zip_add_buffer_ext(_this,_path1,_buf,0,buffer_get_size(_buf),_compressionLevel);
	buffer_delete(_buf);
}

function zip_finalize(_this){
	// zip_finalize(this:zip)
	_this[@2]=false;
	var _o=_this[0];
	var _cdr_size=0;
	var _cdr_offset=0;
	var __g_list=_this[1];
	var __g_index=0;
	while(__g_index<ds_list_size(__g_list)){
		var _f=__g_list[|__g_index++];
		var _namelen=string_byte_length(_f[0]);
		var _extraFieldsLength=0;
		buffer_write(_o,buffer_s32,33639248);
		buffer_write(_o,buffer_u16,20);
		buffer_write(_o,buffer_u16,20);
		buffer_write(_o,buffer_u16,2048);
		buffer_write(_o,buffer_u16,(_f[1]?8:0));
		var _d=_f[5];
		buffer_write(_o,buffer_u16,(((date_get_hour(_d[1])<<11)|(date_get_minute(_d[1])<<5))|(date_get_second(_d[1])>>1)));
		buffer_write(_o,buffer_u16,(((date_get_year(_d[1])-1980<<9)|(date_get_month(_d[1])-1+1<<5))|date_get_weekday(_d[1])));
		buffer_write(_o,buffer_u32,_f[4]);
		buffer_write(_o,buffer_s32,_f[2]);
		buffer_write(_o,buffer_s32,_f[3]);
		buffer_write(_o,buffer_u16,_namelen);
		buffer_write(_o,buffer_u16,_extraFieldsLength);
		buffer_write(_o,buffer_u16,0);
		buffer_write(_o,buffer_u16,0);
		buffer_write(_o,buffer_u16,0);
		buffer_write(_o,buffer_s32,0);
		buffer_write(_o,buffer_s32,_cdr_offset);
		buffer_write(_o,buffer_text,_f[0]);
		_cdr_size+=46+_namelen+_extraFieldsLength;
		_cdr_offset+=30+_namelen+_extraFieldsLength+_f[2];
	}
	buffer_write(_o,buffer_s32,101010256);
	buffer_write(_o,buffer_u16,0);
	buffer_write(_o,buffer_u16,0);
	buffer_write(_o,buffer_u16,ds_list_size(_this[1]));
	buffer_write(_o,buffer_u16,ds_list_size(_this[1]));
	buffer_write(_o,buffer_s32,_cdr_size);
	buffer_write(_o,buffer_s32,_cdr_offset);
	buffer_write(_o,buffer_u16,0);
}

function zip_save(_this,_path1){
	/// zip_save(this:zip, path:string)
	/// @param {zip} this
	/// @param {string} path
	if(_this[2])zip_finalize(_this);
	buffer_save_ext(_this[0],_path1,0,buffer_tell(_this[0]));
}

function zip_get_buffer(_this){
	/// zip_get_buffer(this:zip)->buffer
	/// @param {zip} this
	if(_this[2])zip_finalize(_this);
	return _this[0];
}

function zip_std_haxe_class(_id,_name)constructor{
	// zip_std_haxe_class(id:int, name:string)
	static superClass=undefined; /// @is {haxe_class<any>}
	static marker=undefined; /// @is {any}
	static index=undefined; /// @is {int}
	static name=undefined; /// @is {string}
	self.superClass=undefined;
	self.marker=zip_std_haxe_type_markerValue;
	self.index=_id;
	self.name=_name;
	static __class__="class";
}

function zip_std_haxe_Exception_new(_this,_message,_previous,_native){
	// zip_std_haxe_Exception_new(this:zip_std_haxe_Exception, message:string, ?previous:zip_std_haxe_Exception, ?native:any)
	if(false)show_debug_message(argument[2]);
	_this[@1]=(_native!=undefined?_native:_this);
}

function zip_std_haxe_Exception_create(_message,_previous,_native){
	// zip_std_haxe_Exception_create(message:string, ?previous:zip_std_haxe_Exception, ?native:any)
	var _this=[mt_zip_std_haxe_Exception];
	array_copy(_this,1,mq_zip_std_haxe_Exception,1,1);
	/// @typedef {tuple<any,native:any>} zip_std_haxe_Exception
	switch(argument_count){
		case 1:zip_std_haxe_Exception_new(_this,argument[0]);break;
		case 2:zip_std_haxe_Exception_new(_this,argument[0],argument[1]);break;
		case 3:zip_std_haxe_Exception_new(_this,argument[0],argument[1],argument[2]);break;
		default:show_error("Expected 1..3 arguments.",true);
	}
	return _this;
}

function zip_std_haxe_Exception_isNativeException(_value){
	// zip_std_haxe_Exception_isNativeException(value:any)->bool
	if(is_struct(_value)){
		var _c=variable_struct_get(_value,"__class__");
		if(_c==undefined)return false;
		if(_c==mt_zip_std_haxe_Exception)return true;
		if(!variable_struct_exists(_value,"superClass"))return false;
		for(_c=_c.superClass;is_struct(_c);_c=_c.superClass){
			if(_c==mt_zip_std_haxe_Exception)return true;
		}
	}
	return false;
}

function zip_std_haxe_Exception_thrown(_value){
	// zip_std_haxe_Exception_thrown(value:any)->any
	if(zip_std_haxe_Exception_isNativeException(_value))return _value[1];
	return zip_std_haxe_ValueException_create(_value);
}

function zip_std_haxe_ValueException_create(_value,_previous,_native){
	// zip_std_haxe_ValueException_create(value:any, ?previous:zip_std_haxe_Exception, ?native:any)
	var _this=[mt_zip_std_haxe_ValueException];
	array_copy(_this,1,mq_zip_std_haxe_ValueException,1,2);
	/// @typedef {tuple<any,native:any,value:any>} zip_std_haxe_ValueException
	if(false)show_debug_message(argument[2]);
	zip_std_haxe_Exception_new(_this,string(_value),_previous,_native);
	_this[@2]=_value;
	return _this;
}



/// @typedef {any} ZipEntry