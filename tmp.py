import os
out_dir = '/mnt/local/ST1T/教学视频/'
lcd_dir = '/mnt/lcd/'
for jc_dir in os.listdir(lcd_dir):
    oj_dir = os.path.join(out_dir, jc_dir)
    if not os.path.exists(oj_dir):
        os.mkdir(oj_dir)
    jc_adir = os.path.join(lcd_dir, jc_dir)
    for c_dir in os.listdir(jc_adir):
        m3u8_file = os.path.join(lcd_dir, jc_dir, c_dir, c_dir+'.m3u8')
        out_mp4_file = os.path.join(oj_dir, c_dir+'.mp4')
        ff_cmd = 'ffmpeg -allowed_extensions ALL -i {} -c copy {}'.format(
            m3u8_file,out_mp4_file)
        os.system(ff_cmd)
