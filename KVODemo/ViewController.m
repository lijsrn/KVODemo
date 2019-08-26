//
//  ViewController.m
//  KVODemo
//
//  Created by JH on 2019/8/26.
//  Copyright © 2019 JH. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/**
 数据源
 */
@property(nonatomic,strong) NSMutableArray *dataSource;

/**
 要下单的数据源
 */
@property(nonatomic,strong) NSMutableArray *pendingDataSource;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) UIButton *selectAllButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (int i =0; i <5; i++) {
        Person *person = [Person new];
        person.name = [NSString stringWithFormat:@"参数数据%d",i];
        [self.dataSource addObject:person];
    }
    
    
    //监听pendingDataSource对象是否发生变化
    [self addObserver:self forKeyPath:@"pendingDataSource" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.view addSubview:self.tableView];
    [self configButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    
}

-(void)confirm{
    NSLog(@"-----%@",self.pendingDataSource);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"--%@",change);
  if (self.pendingDataSource.count == self.dataSource.count){
        [self.selectAllButton setSelected:YES];
  }else  {
      [self.selectAllButton setSelected:NO];
  }
}


-(void)configButton{
    self.selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.selectAllButton addGestureRecognizer:pan];
    
    [self.selectAllButton setImage:  [UIImage imageNamed:@"Oval"] forState:UIControlStateNormal];
    [self.selectAllButton setImage:  [UIImage imageNamed:@"getIt"] forState:UIControlStateSelected];
    self.selectAllButton.frame = CGRectMake(self.view.frame.size.width - 50, 350, 50, 50);
//    self.selectAllButton.layer.cornerRadius = 25;
//    self.selectAllButton.layer.masksToBounds = YES;
    [self.selectAllButton addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectAllButton];

    [self.view bringSubviewToFront:self.selectAllButton];
}

//按钮可拖拽
-(void)panAction:(UIPanGestureRecognizer *) recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint newCenter = CGPointMake(recognizer.view.center.x+ translation.x,
                                    recognizer.view.center.y + translation.y);
    newCenter.y = MAX(recognizer.view.frame.size.height/2, newCenter.y);
    newCenter.y = MIN(self.view.frame.size.height - recognizer.view.frame.size.height/2,  newCenter.y);
    newCenter.x = MAX(recognizer.view.frame.size.width/2, newCenter.x);
    newCenter.x = MIN(self.view.frame.size.width - recognizer.view.frame.size.width/2,newCenter.x);
    recognizer.view.center = newCenter;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state==UIGestureRecognizerStateCancelled) {
        CGFloat theCenter = 0;
        if(newCenter.x>self.view.frame.size.width/2 ){
            theCenter = self.view.frame.size.width -60/2;
        }else{
            theCenter = 30;
        }
        [UIView animateWithDuration:0.2 animations:^{
            recognizer.view.center = CGPointMake(theCenter, recognizer.view.center.y+ translation.y);
        }];
    }
}

-(void)selectAllAction:(UIButton *)button{
    if (self.dataSource.count == 0) {
        return;
    }
    
    [button setSelected:!button.isSelected];
    
    if(!button.isSelected){
        for (Person *model in self.dataSource) {
            model.selected = NO;
        }
        [[self mutableArrayValueForKey:@"pendingDataSource"] removeAllObjects];
        //        [self.pendingDataSource removeAllObjects];
    }else{                                                      //全选
        for (Person *model in self.dataSource) {
            model.selected = YES;
        }
        [[self mutableArrayValueForKey:@"pendingDataSource"] removeAllObjects];
        [[self mutableArrayValueForKey:@"pendingDataSource"] addObjectsFromArray:self.dataSource];
    }
    
    [self.tableView reloadData];
    
}

#pragma --mark UITableViewDataSource,UITableViewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    Person *person = self.dataSource[indexPath.row];
    cell.textLabel.text = person.name;
    if (person.selected) {
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Person *person = self.dataSource[indexPath.row];
    if ([self.pendingDataSource containsObject:person]) {
         cell.accessoryType = UITableViewCellAccessoryNone;
        [[self mutableArrayValueForKey:@"pendingDataSource"] removeObject:person];
        person.selected = NO;
    }else{
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [[self mutableArrayValueForKey:@"pendingDataSource"] addObject:person];
        person.selected = YES;
    }
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
      
        _tableView.tableFooterView = [UIView new];

    }
    return _tableView;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];

    self.tableView.frame =self.view.bounds;
    
}

-(NSMutableArray *)pendingDataSource{
    if (!_pendingDataSource) {
        _pendingDataSource = [NSMutableArray array];
    }
    return _pendingDataSource;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
@end
