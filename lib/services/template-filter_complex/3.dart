import 'package:flutter_camera_example/utils/global_state.dart';

final font = GlobalState.getProfileAttribute('font');
String filter3 =
    '''-filter_complex "[0:v]drawbox=x=0:y=ih*0.85:w=iw:h=ih*0.075:color=black@0.75:t=fill[box]; 
    [box]drawtext=fontfile=$font:fontcolor=white:text='למכירה':x=40:y=h*0.80:fontsize=h*0.06[listed]; 
    [listed]drawtext=fontfile=$font:fontcolor=white:text='3':x=w*0.15:y=h*0.87:fontsize=40[left]; 
    [left]drawtext=fontfile=$font:fontcolor=white:text='2':x=w*0.3:y=h*0.87:fontsize=75[center]; 
    [center]drawtext=fontfile=$font:fontcolor=white:text='1,234 מטר רבוע':x=w*0.5:y=h*0.87:fontsize=75[right]; 
    [right]drawtext=fontfile=$font:fontcolor=white:text='שח 1,000,000':x=w*0.8:y=h*0.87:fontsize=55[with_text]; 
    [1:v]scale=-1:ih*0.075[scaled_img]; 
    [with_text][scaled_img]overlay=x=W*0.15-w-5:y=H*0.85[out]"''';
