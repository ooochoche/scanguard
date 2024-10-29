import { Test, TestingModule } from '@nestjs/testing';
import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';
import { ProductDto } from './product.dto';

describe('ProductsController', () => {
  let controller: ProductsController;
  let service: ProductsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProductsController],
      providers: [
        {
          provide: ProductsService,
          useValue: {
            submitProduct: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ProductsController>(ProductsController);
    service = module.get<ProductsService>(ProductsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('submitProduct', () => {
    it('should return IPFS hash on successful submission', async () => {
      const dto: ProductDto = {
        name: 'Test Product',
        image: 'http://example.com/image.jpg',
        manufacturer: 'Test Manufacturer',
        manufactureDate: '2023-01-01',
        expiryDate: '2025-01-01',
      };

      jest
        .spyOn(service, 'submitProduct')
        .mockResolvedValue('QmUiPq1dRygSjwCBAqxvwaJxbGVFyHmPmSrL4YiytJFfkh');

      const result = await controller.submitProduct(dto);
      expect(result).toEqual({
        ipfs_hash: 'QmUiPq1dRygSjwCBAqxvwaJxbGVFyHmPmSrL4YiytJFfkh',
      });
    });

    it('should throw an error if submission fails', async () => {
      const dto: ProductDto = {
        name: 'Test Product',
        image: 'http://example.com/image.jpg',
        manufacturer: 'Test Manufacturer',
        manufactureDate: '2023-01-01',
        expiryDate: '2025-01-01',
      };

      jest
        .spyOn(service, 'submitProduct')
        .mockRejectedValue(new Error('Error uploading to IPFS'));

      await expect(controller.submitProduct(dto)).rejects.toThrow();
    });
  });
});
