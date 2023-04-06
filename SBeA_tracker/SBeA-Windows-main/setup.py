from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
import os
os.system('conda env create -f environment.yml')
dir_path = os.path.dirname(os.path.realpath(__file__))
setup(
    name='deform_conv',
    ext_modules=[
        CUDAExtension('_C', [
            dir_path+'/SocialBehaviorAtlas/train_utils/vistr/models/dcn/deformable/deform_conv.cpp',
            dir_path+'/SocialBehaviorAtlas/train_utils/vistr/models/dcn/deformable/deform_conv_cuda.cu',
            dir_path+'/SocialBehaviorAtlas/train_utils/vistr/models/dcn/deformable/deform_conv_cuda_kernel.cu'],
              include_dirs=["deformable"],
              define_macros = [("WITH_CUDA", None)],
              extra_compile_args={"nvcc":[
                    "-O3",
                    "-DCUDA_HAS_FP16=1",
                    "-D__CUDA_NO_HALF_OPERATORS__",
                    "-D__CUDA_NO_HALF_CONVERSIONS__",
                    "-D__CUDA_NO_HALF2_OPERATORS__"],
                    "cxx":[],}
              )
    ],
    cmdclass={'build_ext': BuildExtension})
