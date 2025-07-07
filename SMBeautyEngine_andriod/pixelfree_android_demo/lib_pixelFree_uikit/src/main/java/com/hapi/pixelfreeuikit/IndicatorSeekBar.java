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

    TextView textView;
    SeekBar seekBar;
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
        LayoutParams lp = (LayoutParams) textView.getLayoutParams();
        seekBarLeftMargin = lp.leftMargin;
        paint = textView.getPaint();
    }

    public void updateTextView(int progress){
        Rect bounds = seekBar.getProgressDrawable().getBounds();
        LayoutParams lp = (LayoutParams) textView.getLayoutParams();
        textView.setText(progress + "");
        paint.getTextBounds("0", 0, 1, textBounds);
        mTextWidth = textBounds.width();
        lp.leftMargin = (bounds.width() * seekBar.getProgress() / seekBar.getMax()) + seekBarLeftMargin + mTextWidth;
        textView.setLayoutParams(lp);
    }

    public void setOnSeekBarChangeListener(SeekBar.OnSeekBarChangeListener listener){
        seekBar.setOnSeekBarChangeListener(listener);
    }

    public SeekBar getSeekBar() {
        return seekBar;
    }
}
