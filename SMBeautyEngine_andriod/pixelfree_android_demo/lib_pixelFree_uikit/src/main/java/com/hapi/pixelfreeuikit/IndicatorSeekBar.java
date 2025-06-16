package com.hapi.pixelfreeuikit;

import android.content.Context;
import android.graphics.Rect;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.Nullable;

public class IndicatorSeekBar extends LinearLayout {

    private TextView textView;
    private SeekBar seekBar;
    TextPaint paint;
    int mTextWidth;
    int seekBarLeftMargin;
    Rect textBounds = new Rect();

    public IndicatorSeekBar(Context context) {
        this(context, null);
    }

    public IndicatorSeekBar(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public IndicatorSeekBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context){
        final LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.view_indicator_seekbar, this);
        
        textView = findViewById(R.id.isb_progress);
        seekBar = findViewById(R.id.isb_seekbar);
        
        // Set initial text and make sure it's visible
        textView.setText("0");
        textView.setVisibility(VISIBLE);
        
        // Add default listener to update text when sliding
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                updateTextView(progress);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
    }

    public void updateTextView(int progress){
        if (textView != null) {
            textView.setText(String.valueOf(progress));
            textView.setVisibility(VISIBLE);
        }
    }

    public void setOnSeekBarChangeListener(SeekBar.OnSeekBarChangeListener listener){
        seekBar.setOnSeekBarChangeListener(listener);
    }

    public SeekBar getSeekBar() {
        return seekBar;
    }
}
