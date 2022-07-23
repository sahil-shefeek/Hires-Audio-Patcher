MODPATH=${0%/*}

# destination
MODAPC=`find $MODPATH/system -type f -name *policy*.conf`
MODAPX=`find $MODPATH/system -type f -name *policy*.xml`
MODAPI=`find $MODPATH/system -type f -name *audio*platform*info*.xml`

# patch audio policy conf
if [ "$MODAPC" ]; then
  if ! grep -Eq deep_buffer_24 $MODAPC; then
    sed -i '/^outputs/a\
  deep_buffer_24 {\
    flags AUDIO_OUTPUT_FLAG_DEEP_BUFFER\
    formats AUDIO_FORMAT_PCM_24_BIT_PACKED|AUDIO_FORMAT_PCM_8_24_BIT\
    sampling_rates 44100|48000\
    bit_width 24\
    app_type 69940\
  }' $MODAPC
  fi
fi

# patch audio policy xml
if [ "$MODAPX" ]; then
  sed -i '/AUDIO_OUTPUT_FLAG_DEEP_BUFFER/a\
                    <profile name="" format="AUDIO_FORMAT_PCM_24_BIT_PACKED"\
                             samplingRates="44100,48000"\
                             channelMasks="AUDIO_CHANNEL_OUT_STEREO,AUDIO_CHANNEL_OUT_MONO"/>\
                    <profile name="" format="AUDIO_FORMAT_PCM_8_24_BIT"\
                             samplingRates="44100,48000"\
                             channelMasks="AUDIO_CHANNEL_OUT_STEREO,AUDIO_CHANNEL_OUT_MONO"/>' $MODAPX

fi

# patch audio platform info
if [ "$MODAPI" ]; then
  if ! grep -Eq '<bit_width_configs>' $MODAPI; then
    sed -i '/<audio_platform_info>/a\
    <bit_width_configs>\
        <device name="SND_DEVICE_OUT_HEADPHONES" bit_width="24"/>\
        <device name="SND_DEVICE_OUT_SPEAKER" bit_width="24"/>\
    </bit_width_configs>' $MODAPI
  fi
  if ! grep -Eq '<device name="SND_DEVICE_OUT_SPEAKER" bit_width=' $MODAPI; then
    sed -i '/<bit_width_configs>/a\
        <device name="SND_DEVICE_OUT_SPEAKER" bit_width="24"/>' $MODAPI
  fi
  if ! grep -Eq '<device name="SND_DEVICE_OUT_HEADPHONES" bit_width=' $MODAPI; then
    sed -i '/<bit_width_configs>/a\
        <device name="SND_DEVICE_OUT_HEADPHONES" bit_width="24"/>' $MODAPI
  fi
  sed -i 's/<device name="SND_DEVICE_OUT_HEADPHONES" bit_width="16"/<device name="SND_DEVICE_OUT_HEADPHONES" bit_width="24"/g' $MODAPI
  sed -i 's/<device name="SND_DEVICE_OUT_SPEAKER" bit_width="16"/<device name="SND_DEVICE_OUT_SPEAKER" bit_width="24"/g' $MODAPI
fi


