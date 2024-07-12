#import <Foundation/Foundation.h>
#import <algorithm>
#import <vector>
#import "turbojpeg.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {

		int num = 12;
		
		const int MAX_ROWS = 4;
		const int MAX_COLS = 3;
		const int MAX_TEXTURE_COUNT = MAX_ROWS*MAX_COLS;
		const int w[2] = {1920,1920>>1};
		const int h[2] = {1080,1080>>1};
		const unsigned char color[MAX_TEXTURE_COUNT][3] = {
			{38,100,238},
			{36,102,228},
			{34,104,218},
			{32,106,208},
			{30,108,198},
			{28,110,188},
			{26,112,178},
			{24,114,168},
			{22,116,158},
			{20,118,148},
			{18,120,138},
			{16,122,128},
		};
		
		if(num>=1) {
			
			if(num>=MAX_TEXTURE_COUNT) num = MAX_TEXTURE_COUNT;
			
			int rows = ((num-1)/(float)MAX_COLS)+1;
			int cols = std::min((int)num,MAX_COLS);
			
			std::vector<unsigned char *> yuv;

			for(int t=0; t<num; t++) {
				
				yuv.push_back(new unsigned char[w[0]*h[0]+w[1]*h[1]*2]);

				for(int i=0; i<h[0]; i++) {
					
					unsigned char *y = yuv[t] + i*w[0];
					unsigned char *u = yuv[t] + w[0]*h[0] + (i>>1)*w[1];
					unsigned char *v = yuv[t] + w[0]*h[0] + (w[1])*(h[1]) + (i>>1)*w[1];
					
					for(int j=0; j<w[0]; j++) {
						
						*y++ = color[t][0];
						
						if(((i&1)==0)&&((j&1)==0)) {
							
							*u++ = color[t][1];
							*v++ = color[t][2];
						}
					}
				}
			}
			
			int tw[2] = {
				w[0]*rows,
				w[1]*rows
			};
			
			int th[2] = {
				h[0]*cols,
				h[1]*cols
			};

			unsigned char *texture = new unsigned char[(tw[0]*th[0])+(tw[1]*th[1])*2];

			for(int t=0; t<num; t++) {
				
				unsigned char *y = yuv[t];
				unsigned char *u = yuv[t] + w[0]*h[0];
				unsigned char *v = yuv[t] + w[0]*h[0] + w[1]*h[1];
				
				int ox = t/MAX_COLS;
				int oy = t%MAX_COLS;
				
				for(int i=0; i<h[0]; i++) {
					for(int j=0; j<w[0]; j++) {
						texture[(i+h[0]*oy)*tw[0]+(j+w[0]*ox)] = *y++;
					}
				}
			
				for(int i=0; i<h[1]; i++) {
					for(int j=0; j<w[1]; j++) {
						texture[(tw[0]*th[0])+(i+h[1]*oy)*tw[1]+(j+w[1]*ox)] = *u++;
					}
				}
			
				for(int i=0; i<h[1]; i++) {
					for(int j=0; j<w[1]; j++) {
						texture[(tw[0]*th[0])+(tw[1]*th[1])+(i+h[1]*oy)*tw[1]+(j+w[1]*ox)] = *v++;
					}
				}
			}
			
			NSData *jpg = nil;
			unsigned char *buffer = tjAlloc((int)tjBufSizeYUV2(tw[0],2,tw[0],TJSAMP_420));
			
			tjhandle handle = tjInitCompress();
			if(handle) {
				unsigned long bufferSize = 0;
				if(tjCompressFromYUV(handle,texture,tw[0],2,th[0],TJSAMP_420,&buffer,&bufferSize,75,TJFLAG_NOREALLOC)==0) {
					jpg = [[NSData alloc] initWithBytes:buffer length:bufferSize];
					[jpg writeToFile:[NSString stringWithFormat:@"./texture.jpg"] atomically:YES];
				}
				tjDestroy(handle);
			}
			
			for(int t=0; t<num; t++) {
				if(yuv[t]) delete[] yuv[t];
			}
			
			yuv.clear();
			yuv.shrink_to_fit();
			
			if(texture) delete[] texture;
		}
	}
}