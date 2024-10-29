import { Test, TestingModule } from '@nestjs/testing';
import { ProductsService } from './products.service';
import { ProductDto } from './product.dto';

describe('ProductsService', () => {
  let service: ProductsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ProductsService],
    }).compile();

    service = module.get<ProductsService>(ProductsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('submitProduct', () => {
    it('should successfully submit a product and return IPFS hash', async () => {
      const dto: ProductDto = {
        name: 'Test Product',
        image: 'http://example.com/image.jpg',
        manufacturer: 'Test Manufacturer',
        manufactureDate: '2023-01-01',
        expiryDate: '2025-01-01',
      };
      
      jest.spyOn(service, 'pinToIPFS').mockResolvedValue({ IpfsHash: 'QmUiPq1dRygSjwCBAqxvwaJxbGVFyHmPmSrL4YiytJFfkh' });

      const result = await service.submitProduct(dto);
      expect(result).toEqual('QmUiPq1dRygSjwCBAqxvwaJxbGVFyHmPmSrL4YiytJFfkh');
    });

    it('should throw an error if pinToIPFS fails', async () => {
      const dto: ProductDto = {
        name: 'Test Product',
        image: 'http://example.com/image.jpg',
        manufacturer: 'Test Manufacturer',
        manufactureDate: '2023-10-01',
        expiryDate: '2025-01-01',
      };

      jest.spyOn(service, 'pinToIPFS').mockRejectedValue(new Error('Error uploading to IPFS'));

      await expect(service.submitProduct(dto)).rejects.toThrow('Error uploading to IPFS');
    });
  });
});
