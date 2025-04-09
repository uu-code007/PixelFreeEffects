
import com.hapi.pixelfree.PixelFree;
import com.hapi.pixelfree.PFDetectFormat;
import com.hapi.pixelfree.PFIamgeInput;
import com.hapi.pixelfree.PFSrcType;
import com.hapi.pixelfree.PFBeautyFiterType;

public class PreprocessorFixelFree {

    // 1. 初始化
    // 注意最好在视频同意 GL 上下文
    private PixelFree mPixelFree = new PixelFree();

    @Override
    public void onPreProcessFrame() {
        PFIamgeInput pxInput = new PFIamgeInput();
        if (mPixelFree.isCreate()) {
            int Y = outFrame.format.getHeight() * outFrame.format.getWidth();
            int UV = outFrame.format.getHeight() * outFrame.format.getWidth()/2;

            byte[] uv = new byte[outFrame.image.length-Y];
            System.arraycopy(outFrame.image, Y, uv, 0, outFrame.image.length-Y);

            pxInput.setWigth(outFrame.format.getWidth());
            pxInput.setHeight(outFrame.format.getHeight());
            pxInput.setP_data0(outFrame.image);
            pxInput.setP_data1(uv);
            pxInput.setStride_0(outFrame.format.getWidth());
            pxInput.setStride_1(outFrame.format.getWidth()/2);
            pxInput.setFormat(PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21);
            pxInput.setRotationMode(PFRotationMode.PFRotationMode90);
            pxInput.setTextureID(0);
            mPixelFree.processWithBuffer(pxInput);


            // int Y = w * h;
            // int UV = w * h/2;
            // byte[] uv = new byte[data-Y];
            // System.arraycopy(data, Y, uv, 0, w*h*3/2-Y);
            // input.setWigth(w);
            // input.setHeight(h);
            // input.setP_data0(data);
            // input.setP_data1(uv);
            // input.setStride_0(w);
            // input.setStride_1(w/2);
            // input.setFormat(PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21);
            // input.setRotationMode(PFRotationMode.PFRotationMode270);
            // input.setTextureID(0);
            // input.processWithBuffer(pxInput);
        } else {

            // 授权 
            mPixelFree.create();
            byte[] bytes = mPixelFree.readBundleFile(mContext, "pixelfreeAuth.lic");
            mPixelFree.auth(mContext, bytes, bytes.length);

            byte[] bytes2 = mPixelFree.readBundleFile(mContext, "filter_model.bundle");
            mPixelFree.createBeautyItemFormBundle(
                bytes2,
                bytes2.length,
                PFSrcType.PFSrcTypeFilter
        );

            // 默认设置一个瘦脸
            mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeFace_narrow,1
            );

        }
    }

}
