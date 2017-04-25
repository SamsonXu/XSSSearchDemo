//
//  XSSearchViewController.m
//  XSGitDemo
//
//  Created by iOS－Dev on 2017/4/20.
//  Copyright © 2017年 iOS－Dev. All rights reserved.
//

#import "XSSearchViewController.h"
#import "MyControl.h"
#import "Define.h"
#import "InfoModel.h"

#define BtnTextColor KColorRGB(230, 113, 62)
@interface XSSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UISearchBar *_searchBar;//搜索栏
    UITableView *_tableView;//主视图
    UIView *_popView;//筛选视图
    UIButton *_lastBtn;//筛选按钮暂存
    
    
    
}

@property (nonatomic, copy) NSString *queryText;//搜索字段

@property (nonatomic, assign) NSInteger type;//筛选类型

@property (nonatomic, strong) NSMutableArray *dataArray;//源数据

@property (nonatomic, strong) NSMutableArray *resultArray;//搜索数据

@end

/** 定义的数据筛选类型 */
typedef NS_ENUM(NSInteger,DateType) {
 
    DateTypeAll,            //所有数据
    DateTypePositive,       //正面
    DateTypeVillain         //反面
};

@implementation XSSearchViewController

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (NSMutableArray *)resultArray{
    if (!_resultArray) {
        _resultArray = [[NSMutableArray alloc]init];
    }
    return _resultArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    
    [self loadData];
}

/** 构建UI视图*/
- (void)createUI{
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIButton *rightItem = [MyControl buttonWithFram:CGRectMake(0, 0, 40, 20) title:@"筛选" imageName:nil];
    [rightItem addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightItem];
    
    [self addSearchBar];
    
    [self addTableView];
    
    [self createPopView];
    
    /** 给View添加手势控制筛选弹框的隐藏*/
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapClick:(UIGestureRecognizer *)sender{
    _popView.hidden = YES;
    [_searchBar resignFirstResponder];
}

- (void)addTableView{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), KScreenWidth, KScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [MyControl setExtraCellLineHidden:_tableView];
    [self.view addSubview:_tableView];
    
}

- (void)rightClick:(UIButton *)sender{
    _popView.hidden = !_popView.hidden;
}

/** 构建数据*/
- (void)loadData{
    
    NSArray *texts = @[@"李达康",@"侯亮平",@"陆亦可",@"沙瑞金",@"易学习",@"祁同伟",@"赵瑞龙",@"丁义珍",@"刘新建"];
    NSArray *types = @[@"1",@"1",@"1",@"1",@"1",@"2",@"2",@"2",@"2"];
    
    for (int i = 0; i < texts.count; i++) {
        InfoModel *model = [[InfoModel alloc]init];
        model.infoText = texts[i];
        model.infoType = [types[i] integerValue];
        [self.dataArray addObject:model];
    }
    
    _resultArray = [[NSMutableArray alloc]initWithArray:_dataArray];
    [_tableView reloadData];
}

#pragma mark 筛选视图
- (void)createPopView{
    
    _popView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_popView];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(KScreenWidth-115, 64, 115, 130)];
    contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [_popView addSubview:contentView];
    _popView.hidden = YES;
    
    
    NSArray *array = @[@"全部",@"正面人物",@"反面人物"];
    for (int i = 0; i < array.count; i++) {
        
        UIButton *btn = [MyControl buttonWithFram:CGRectMake((115-65)/2, 15+(25+12)*i, 65, 25) title:array[i] imageName:nil tag:30+i];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setImage:[UIImage imageNamed:@"sale_btnback"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [MyControl labelWithTitle:array[i] fram:CGRectMake(0, 0, 65, 25) fontOfSize:15];
        label.tag = 5;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [btn addSubview:label];
        
        if (i == 0) {
            btn.selected = YES;
            label.textColor = BtnTextColor;
            _lastBtn = btn;
        }
        [contentView addSubview:btn];
        
    }

}

- (void)popBtnClick:(UIButton *)sender{
    
    _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, 0);
    if (sender.selected == YES) {
        return;
    }
    
    sender.selected = YES;
    UILabel *label = [sender viewWithTag:5];
    label.textColor = BtnTextColor;
    if (_lastBtn) {
        _lastBtn.selected = NO;
        UILabel *label = [_lastBtn viewWithTag:5];
        label.textColor = [UIColor whiteColor];
    }
    _lastBtn = sender;
    switch (sender.tag) {
        case 30:
        {
            _type = DateTypeAll;
            
        }
            break;
        case 31:
        {
            _type = DateTypePositive;
        }
            break;
        case 32:
        {
            _type = DateTypeVillain;
        }
            break;
        default:
            break;
    }
    
    [_resultArray removeAllObjects];
    [self searchInfo];
}

- (void)addSearchBar{
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, 40)];
    _searchBar.placeholder = @"试试搜索人物信息";
    _searchBar.delegate = self;
    _searchBar.barTintColor = [UIColor whiteColor];
    _searchBar.backgroundImage = [UIImage new];
    [self.view addSubview:_searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchBar.showsCancelButton = YES;
    
}

/** 取消搜索后将dataArray的数据重新复制给resultArray，刷新界面*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    
    _searchBar.showsCancelButton = NO;
    _searchBar.text = nil;
    _queryText = nil;
    [searchBar resignFirstResponder];
    
    _resultArray = [[NSMutableArray alloc]initWithArray:_dataArray];
    [MyControl dismissFromView:self.view];
    [_tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    _queryText = searchBar.text;
    
    [_resultArray removeAllObjects];
    [_searchBar resignFirstResponder];
    [self searchInfo];
}

- (void)searchInfo{
    
    /**
    
     这里我做了简单的本地检索，通过截取字符串进行简单比较。
     但是在数据较多的情况下，一般我们通过获取searchBar上的文字，向后台发送搜索字段，接收后台返回的数据再进行数据的呈现。
    */
    
    NSInteger strLength = _queryText.length;
    /** 搜索字段为空时，显示所有数据*/
    if (strLength == 0) {
        
        for (InfoModel *model in self.dataArray) {
        
            if (model.infoType == _type || _type == 0) {
                [_resultArray addObject:model];
            }
        }
        
        [_tableView reloadData];
        _popView.hidden = YES;
        return;
    }
    
    /** 搜索条件不为空时，便利数据进行筛选*/
    for (InfoModel *model in self.dataArray) {
        
        NSString *tempStr = [model.infoText substringToIndex:strLength];
        if ([tempStr isEqualToString:_queryText] && (model.infoType == _type || _type == DateTypeAll)) {
            [_resultArray addObject:model];
        }
    }
    
    [_tableView reloadData];
    _popView.hidden = YES;
    
    /** 无数据时添加提示*/
    if (_resultArray.count == 0) {
        [MyControl showWithFram:_tableView.frame propmt:@"暂无搜索结果" onView:self.view];
        [self.view bringSubviewToFront:_popView];
    }else{
        [MyControl dismissFromView:self.view];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ide = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ide];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ide];
    }
    InfoModel *model = _resultArray[indexPath.row];
    cell.textLabel.text = model.infoText;
    if (model.infoType == 1) {
        cell.detailTextLabel.text = @"正面人物";
    }else if (model.infoType == 2){
        cell.detailTextLabel.text = @"反面人物";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
