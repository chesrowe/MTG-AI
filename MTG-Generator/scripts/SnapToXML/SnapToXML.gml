/// @return _xml string that encodes the provided struct
/// 
/// @param struct  The data to encode
/// 
/// @jujuadams 2022-10-30

function SnapTo_xml(_struct)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    SnapBufferWrite_xml(_buffer, _struct);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    return _string; 
}