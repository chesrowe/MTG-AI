/// Decodes an _xml string and outputs a struct
/// 
/// @param string  String to decode
/// 
/// @jujuadams 2022-10-30

function SnapFrom_xml(_string)
{
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    var _data = SnapBufferRead_xml(_buffer, 0, buffer_get_size(_buffer));
    buffer_delete(_buffer);
    return _data;
}